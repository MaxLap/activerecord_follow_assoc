module ActiveRecordFollowAssoc::QueryMethods
  def follow_assoc(*association_names)
    options = association_names.extract_options!
    ActiveRecordFollowAssoc::CoreLogic.follow_assoc(self, association_names, options)
  end
end
