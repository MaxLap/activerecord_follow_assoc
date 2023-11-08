# frozen_string_literal: true

require "bundler/setup"

require_relative "../../lib/activerecord_follow_assoc"

if ENV["DB"] == "mysql" && [ActiveRecord::VERSION::MAJOR, ActiveRecord::VERSION::MINOR].join('.') < '5.1'
  puts "Exiting from tests with MySQL as success without doing them."
  puts "This is because automated test won't seem to run MySQL for some reason for this old Rails version."
  exit 0
end

require "active_support/all"

require_relative "database_setup"
require_relative "ignore_optional_in_42_and_less"
require_relative "models"
require_relative "schema"

require "niceql" if RUBY_VERSION >= "2.3.0"
