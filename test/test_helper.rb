# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path('../db/migrate', __dir__)
require "rails/test_help"

# Filter out Minitest backtrace while allowing backtrace from other libraries to be shown.
# Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
  ActiveSupport::TestCase.fixtures :all
end

require "minitest/mock"
require "mocha/minitest"
require "webmock/minitest"

require "minitest/reporters"
Minitest::Reporters.use!

require "factory_bot_rails"
class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
end

ActiveRecord.verify_foreign_keys_for_fixtures = false # Temporarily handle RuntimeError: Foreign key violations found in your fixture data.
