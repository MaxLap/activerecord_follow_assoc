if ActiveRecord.gem_version < Gem::Version.new("5.0")
  module ActiveRecordFollowAssoc::IgnoreOptionalOption
    def build(model, name, scope, options, &block)
      options.delete(:optional)
      if scope.is_a?(Hash)
        scope.delete(:optional)
      end
      super
    end
  end

  ActiveRecord::Associations::Builder::Association.singleton_class.prepend(ActiveRecordFollowAssoc::IgnoreOptionalOption)
end
