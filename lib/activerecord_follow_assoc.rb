# frozen_string_literal: true

require "active_record_follow_assoc/version"
require "active_record"

module ActiveRecordFollowAssoc
  def self.default_options
    @default_options ||= {
        ignore_limit: false,
    }
  end

  require_relative "active_record_follow_assoc/exceptions"
  require_relative "active_record_follow_assoc/core_logic"
  require_relative "active_record_follow_assoc/query_methods"

  module ClassDelegates
    # Delegating the methods in QueryMethods from ActiveRecord::Base to :all. Same thing ActiveRecord does for #where.
    new_query_methods = QueryMethods.public_instance_methods
    delegate(*new_query_methods, to: :all)
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord.eager_load!

  ActiveRecord::Relation.include(ActiveRecordFollowAssoc::QueryMethods)
  ActiveRecord::Base.extend(ActiveRecordFollowAssoc::ClassDelegates)
end
