

module ActiveRecordFollowAssoc::QueryMethods
  # Returns a new relation which will return records of the specified associations of
  # the models.
  #
  # You could say this is a way of doing a +#flat_map+ of the association on the result
  # of the current relation, but without loading the records of the first relation and
  # without having to worry about eager loading.
  #
  # Examples (with equivalent +#flat_map+)
  #
  #   # Comments of published posts
  #   Post.where(published: true).follow_assoc(:comments)
  #   # Somewhat equivalent to. (Need to use preload to avoid the N+1 query problem)
  #   Post.where(published: true).preload(:comments).flat_map(:comments)
  #
  # The main differences between the +#flat_map+ and +#follow_assoc+ approaches:
  # * +#follow_assoc+ returns a query (or relation or scope, however you call it), so you can
  #   use other scoping methods, such as +#where+, +#limit+, +#order+.
  # * +#flat_map+ returns an Array, so you cannot use other scoping methods.
  # * +#flat_map+ must be used with eager loading. Forgetting to do so makes N+1 query likely.
  # * +#follow_assoc+ only loads the final matched records.
  # * +#flat_map+ loads every associations on the way, this is wasteful when you don't need them.
  #
  # [association_names]
  #   The associations that you want to follow. They are your +#belongs_to+, +#has_many+,
  #   +#has_one+, +#has_and_belongs_to_many+.
  #
  #   If you pass in more than one, they will be followed in order.
  #
  # [options]
  #   Following are the options that can be passed as last argument.
  #
  #   If you are passing multiple association_names, the options only affect the last association.
  #
  # [option :ignore_limit]
  #   When true, +#limit+ and +#offset+ that are set from default_scope, on associations, and from
  #   +#has_one+ are ignored. <br>
  #   Removing the limit from +#has_one+ makes them be treated like a +#has_many+.
  #
  #   Main reasons to use ignore_limit: true
  #   * Needed for MySQL to be able to do anything with +#has_one+ associations because MySQL
  #     doesn't support sub-limit. <br>
  #     See {MySQL doesn't support limit}[https://github.com/MaxLap/activerecord_follow_assoc#mysql-doesnt-support-sub-limit] <br>
  #     Note, this does mean the +#has_one+ will be treated as if it was a +#has_many+ for MySQL too.
  #   * You have a +#has_one+ association which you know can never have more than one record and are
  #     dealing with a heavy/slow query. The query used to deal with +#has_many+ is less complex, and
  #     may prove faster.
  #   * For this one special case, you want to check the other records that match your has_one
  def follow_assoc(*association_names)
    options = association_names.extract_options!
    ActiveRecordFollowAssoc::CoreLogic.follow_assoc(self, association_names, options)
  end
end
