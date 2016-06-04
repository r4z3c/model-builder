require 'active_record'
require 'simplecov'
require 'support/database_connection'

SimpleCov.start

require 'model_builder'

Spec::Support::DatabaseConnection.establish_sqlite_connection

RSpec.configure do |config|
  config.after(:suite) do
    ModelBuilder.clean
  end
end