require 'spec_helper'
require 'support/database_connection'

Spec::Support::DatabaseConnection.establish_sqlite_connection

# the abstraction:

module NameUtils
  def self.map_all_names
    to_a.map &:name
  end
end

describe NameUtils do

  before do
    create_dogs_model
    populate_dogs_table
  end

  after { ModelBuilder.clean }

  it do
    puts 'hi'
  end

  def create_dogs_model
    ModelBuilder.build 'Dog', {
      includes: [NameUtils],
      attributes: { name: :string },
      validates: [:name, presence: true]
    }
  end

  def populate_dogs_table
    3.times {|i| Dog.create! name: "Dog #{i}" }
  end

end