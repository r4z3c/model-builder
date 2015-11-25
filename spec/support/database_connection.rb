require 'model_builder'

module Spec
  module Support
    module DatabaseConnection

      def self.establish_sqlite_connection
        database = "#{File.dirname(__FILE__)}/../../tmp/model_builder-test.sqlite3"

        ::ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: database
      end

    end
  end
end