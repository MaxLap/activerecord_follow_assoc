# See QueryMethods
module ActiveRecordFollowAssoc

end

module ActiveRecordFollowAssoc::QueryMethods
  # Query the specified association of the records that the current query would return.
  #
  # Returns a new relation (also known as a query) which:
  # * targets the association's model.
  #   So +Post.follow_assoc(:comments)+ will return comments.
  # * only returns the records that are associated with those that the receiver would return.
  #   So +Post.where(published: true).follow_assoc(:comments)+ only returns the comments of
  #   published posts.
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
  # * +#follow_assoc+ returns a relation (or query or scope, however you call it), so you can
  #   use other scoping methods, such as +#where+, +#limit+, +#order+.
  # * +#flat_map+ returns an Array, so you cannot use other scoping methods.
  # * +#flat_map+ must be used with eager loading. Forgetting to do so makes N+1 query likely.
  # * +#follow_assoc+ only loads the final matched records.
  # * +#flat_map+ loads every associations on the way, this is wasteful when you don't need them.
  #
  # [association_names]
  #   The first argument(s) are the associations that you want to follow. They are the names of
  #   your +#belongs_to+, +#has_many+, +#has_one+, +#has_and_belongs_to_many+.
  #
  #   If you pass in more than one, they will be followed in order.
  #   Ex: +Post.follow_assoc(:comments, :author)+ gives you the authors of the comments of the posts.
  #
  # [options]
  #   Following are the options that can be passed as last argument.
  #
  #   If you are passing multiple association_names, the options only affect the last association.
  #
  # [option :ignore_limit]
  #   When true, +#has_one+ will be treated like a +#has_many+.
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
  #
  # [option :poly_belongs_to]
  #   If the last association of association_names is a polymorphic belongs_to, then by default,
  #   +#follow_assoc+ will raise an exception. This is because there are many unrelated models
  #   that could be the one referred to by the records, but an ActiveRecord relation can only
  #   target a single Model.
  #
  #   For this reason, you must choose which Model to "look into" when following a polymorphic
  #   belongs_to. This is what the :poly_belongs_to option does.
  #
  #   For example, you can't just go from "Picture" and follow_assoc the polymorphic belongs_to
  #   association "imageable". But if what you are looking for is only the employees, then this works:
  #     employee_scope = pictures_scope.follow_assoc(:imageable, poly_belongs_to: Employee)
  #
  def follow_assoc(*association_names)
    options = association_names.extract_options!
    ActiveRecordFollowAssoc::CoreLogic.follow_assoc(self, association_names, options)
  end
end
