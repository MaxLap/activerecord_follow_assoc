$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require_relative "load_test_env"

module SpecHelpersInTests

end

module SpecHelpersAroundTests

end

RSpec::Matchers.define(:be_one_of) do |expected|
  match do |actual|
    expected.include?(actual)
  end

  failure_message do |actual|
    "expected one of #{expected}, got #{actual}"
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.include SpecHelpersInTests
  config.extend SpecHelpersAroundTests

  config.before(:each) do
    ActiveRecord::Base.connection.begin_transaction joinable: false, _lazy: false
  end

  config.after(:each) do
    connection = ActiveRecord::Base.connection
    connection.rollback_transaction if connection.transaction_open?
  end

  if %w(1 true).include?(ENV["SQL_WITH_FAILURES"])
    config.before(:each) do
      @prev_logger = ActiveRecord::Base.logger
      @my_logged_string_io = StringIO.new
      @my_logger = Logger.new(@my_logged_string_io)
      @my_logger.formatter = proc do |severity, datetime, progname, msg|
        "#{msg}\n"
      end
      ActiveRecord::Base.logger = @my_logger
    end

    config.after do |test_case|
      ActiveRecord::Base.logger = @prev_logger

      next if test_case.exception.nil? || test_case.skipped?

      @my_logged_string_io.rewind
      logged_lines = @my_logged_string_io.readlines

      # Ignore lines that are about the savepoints. Need to remove color codes first.
      logged_lines.reject! { |line| line.gsub(/\e\[[0-9;]*m/, "")[/\)\s*(?:RELEASE )?SAVEPOINT/i] }

      logged_string = logged_lines.join
      if logged_string.present?
        exc = test_case.exception
        orig_message = exc.message
        exc.define_singleton_method(:message) do
          "#{orig_message}\n#{logged_string}"
        end
      end
    end
  end
end
