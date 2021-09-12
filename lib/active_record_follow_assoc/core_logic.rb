require_relative "active_record_compat"

module ActiveRecordFollowAssoc
  module CoreLogic
    # Arel table used for aliasing when handling recursive associations (such as parent/children)
    ALIAS_TABLE = Arel::Table.new("_ar_follow_assoc_alias_")

    # Returns the SQL for checking if any of the received relation exists.
    # Uses a OR if there are multiple relations.
    # => "EXISTS (SELECT... *relation1*) OR EXISTS (SELECT... *relation2*)"
    def self.sql_for_any_exists(relations)
      relations = [relations] unless relations.is_a?(Array)
      relations = relations.reject { |rel| rel.is_a?(ActiveRecord::NullRelation) }
      sqls = relations.map { |rel| "EXISTS (#{rel.select('1').to_sql})" }
      if sqls.size > 1
        "(#{sqls.join(" OR ")})" # Parens needed when embedding the sql in a `where`, because the OR could make things wrong
      elsif sqls.size == 1
        sqls.first
      else
        "0=1"
      end
    end


    def self.follow_assoc(relation, association_names, options_for_last_assoc = {})
      association_names[0...-1].each do |association_name|
        relation = follow_one_assoc(relation, association_name)
      end
      follow_one_assoc(relation, association_names.last, options_for_last_assoc)
    end

    def self.follow_one_assoc(relation, association_name, options = {})
      reflection = fetch_reflection(relation, association_name)

      if reflection.scope && reflection.scope.arity != 0
        raise ArgumentError, <<-MSG.squish
            The association scope '#{name}' is instance dependent (the scope
            block takes an argument). Following instance dependent scopes is
            not supported.
        MSG
      end

      reflection_chain, constraints_chain = ActiveRecordFollowAssoc::ActiveRecordCompat.chained_reflection_and_chained_constraints(reflection)

      # Chained stuff is in reverse order, we want it in forward order
      reflection_chain = reflection_chain.reverse
      constraints_chain = constraints_chain.reverse

      reflection_chain.each_with_index do |sub_reflection, i|
        klass = class_for_reflection(sub_reflection, options[:poly_belongs_to])
        alias_scope, join_constraints = wrapper_and_join_constraints(sub_reflection, options[:poly_belongs_to])

        constraints_relation = resolve_constraints(sub_reflection, klass, constraints_chain[i])
        constraints_relation = constraints_relation.unscope(:limit, :offset, :order) if option_value(options, :ignore_limit)

        if constraints_relation.limit_value
          if alias_scope
            raise "#{sub_reflection.name} is a recursive has_one, this is not supported by follow_assoc."
          end
          sub_relation = constraints_relation.where(join_constraints).unscope(:select).select(klass.primary_key)

          relation = relation.joins(sub_reflection.name)
                             .unscope(:select)
                             .select("#{klass.quoted_table_name}.*")
                             .where("#{klass.quoted_table_name}.#{klass.quoted_primary_key} IN (#{sub_relation.to_sql})")

          relation = klass.unscoped.from("(#{relation.to_sql}) #{klass.quoted_table_name}")
        else
          if alias_scope
            relation = alias_scope.where(sql_for_any_exists(relation.where(join_constraints)))
            join_constraints = nil
          end

          relation = klass.unscoped.where(sql_for_any_exists(relation.where(join_constraints)))
          relation = relation.merge(constraints_relation)
        end
      end

      relation
    end

    def self.fetch_reflection(relation_klass, association_name)
      association_name = ActiveRecordCompat.normalize_association_name(association_name)
      reflection = relation_klass._reflections[association_name]

      if reflection.nil?
        # Need a fake record because this exception expects a record...
        raise ActiveRecord::AssociationNotFoundError.new(relation_klass.new, association_name)
      end

      reflection
    end

    def self.wrapper_and_join_constraints(reflection, poly_belongs_to_klass = nil)
      join_keys = ActiveRecordCompat.join_keys(reflection, poly_belongs_to_klass)

      key = join_keys.key
      foreign_key = join_keys.foreign_key

      table = (poly_belongs_to_klass || reflection.klass).arel_table
      foreign_klass = reflection.send(:actual_source_reflection).active_record
      foreign_table = foreign_klass.arel_table

      if table.name == foreign_table.name
        alias_scope = build_alias_scope_for_recursive_association(reflection, poly_belongs_to_klass)
        table = ALIAS_TABLE
      end

      constraints = table[key].eq(foreign_table[foreign_key])

      if reflection.type
        # Handling of the polymorphic has_many/has_one's type column
        constraints = constraints.and(table[reflection.type].eq(foreign_klass.base_class.name))
      end

      if poly_belongs_to_klass
        constraints = constraints.and(foreign_table[reflection.foreign_type].eq(poly_belongs_to_klass.base_class.name))
      end

      [alias_scope, constraints]
    end

    def self.resolve_constraints(reflection, klass, constraints)
      relation = klass.default_scoped
      assoc_scope_allowed_lim_off = assoc_scope_to_keep_lim_off_from(reflection)

      constraints.each do |callable|
        assoc_constraint_relation = klass.unscoped.instance_exec(nil, &callable)

        if callable != assoc_scope_allowed_lim_off
          # I just want to remove the current values without screwing things in the merge below
          # so we cannot use #unscope
          assoc_constraint_relation.limit_value = nil
          assoc_constraint_relation.offset_value = nil
          assoc_constraint_relation.order_values = []
        end

        # Need to use merge to replicate the Last Equality Wins behavior of associations
        # https://github.com/rails/rails/issues/7365
        relation = relation.merge(assoc_constraint_relation)
      end

      relation = relation.limit(1) if reflection.macro == :has_one

      if user_defined_actual_source_reflection(reflection).macro == :belongs_to
        relation = relation.unscope(:limit, :offset, :order)
      end
      relation
    end

    def self.build_alias_scope_for_recursive_association(reflection, poly_belongs_to_klass)
      klass = poly_belongs_to_klass || reflection.klass
      table = klass.arel_table
      primary_key = klass.primary_key
      foreign_klass = reflection.send(:actual_source_reflection).active_record

      alias_scope = foreign_klass.base_class.unscoped
      alias_scope = alias_scope.from("#{table.name} #{ALIAS_TABLE.name}")
      alias_scope = alias_scope.where(table[primary_key].eq(ALIAS_TABLE[primary_key]))
      alias_scope
    end

    def self.class_for_reflection(reflection, on_poly_belongs_to)
      actual_source_reflection = user_defined_actual_source_reflection(reflection)

      if poly_belongs_to?(actual_source_reflection)
        if reflection.options[:source_type]
          [reflection.options[:source_type].safe_constantize].compact
        else
          if on_poly_belongs_to.nil?
            msg = String.new
            if actual_source_reflection == reflection
              msg << "Association #{reflection.name.inspect} is a polymorphic belongs_to. "
            else
              msg << "Association #{reflection.name.inspect} is a :through relation that uses a polymorphic belongs_to"
              msg << "#{actual_source_reflection.name.inspect} as source without without a source_type. "
            end
            msg << "This is not supported by ActiveRecord when doing joins, but it is by FollowAssoc. However, "
            msg << "you must pass the :poly_belongs_to option to specify what to do in this case.\n"
            msg << "See the :poly_belongs_to option at https://maxlap.dev/activerecord_follow_assoc/ActiveRecordFollowAssoc/QueryMethods.html"
            raise ActiveRecordFollowAssoc::PolymorphicBelongsToWithoutClasses, msg
          elsif on_poly_belongs_to.is_a?(Class) && on_poly_belongs_to < ActiveRecord::Base
              on_poly_belongs_to
          else
            raise ArgumentError, "Received a bad value for :poly_belongs_to: #{on_poly_belongs_to.inspect}"
          end
        end
      else
        reflection.klass
      end
    end

    # Returns the deepest user-defined reflection using source_reflection.
    # This is different from #send(:actual_source_reflection) because it stops on
    # has_and_belongs_to_many associations, where as actual_source_reflection would continue
    # down to the belongs_to that is used internally.
    def self.user_defined_actual_source_reflection(reflection)
      loop do
        return reflection if reflection == reflection.source_reflection
        return reflection if has_and_belongs_to_many?(reflection)
        reflection = reflection.source_reflection
      end
    end

    def self.assoc_scope_to_keep_lim_off_from(reflection)
      # For :through associations, it's pretty hard/tricky to apply limit/offset/order of the
      # whole has_* :through. For now, we only apply those of the direct associations from one model
      # to another that the :through uses and we ignore the limit/offset/order from the scope of has_* :through.
      #
      # The exception is for has_and_belongs_to_many, which behind the scene, use a has_many :through.
      # For those, since we know there is no limits on the internal has_many and the belongs_to,
      # we can do a special case and handle their limit. This way, we can treat them the same way we treat
      # the other macros, we only apply the limit/offset/order of the deepest user-define association.
      user_defined_actual_source_reflection(reflection).scope
    end

    # Gets the value from the options or fallback to default
    def self.option_value(options, key)
      options.fetch(key) { ActiveRecordFollowAssoc.default_options[key] }
    end

    def self.poly_belongs_to?(reflection)
      reflection.macro == :belongs_to && reflection.options[:polymorphic]
    end

    # Return true if #user_defined_actual_source_reflection is a has_and_belongs_to_many
    def self.actually_has_and_belongs_to_many?(reflection)
      has_and_belongs_to_many?(user_defined_actual_source_reflection(reflection))
    end

    # Because we work using Model._reflections, we don't actually get the :has_and_belongs_to_many.
    # Instead, we get a has_many :through, which is was ActiveRecord created behind the scene.
    # This code detects that a :through is actually a has_and_belongs_to_many.
    def self.has_and_belongs_to_many?(reflection) # rubocop:disable Naming/PredicateName
      parent = ActiveRecordCompat.parent_reflection(reflection)
      parent && parent.macro == :has_and_belongs_to_many
    end
  end
end
