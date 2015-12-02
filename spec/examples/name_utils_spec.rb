require 'spec_helper'
require 'support/database_connection'

Spec::Support::DatabaseConnection.establish_sqlite_connection

module NameUtils extend ActiveSupport::Concern
  included do
    define_singleton_method :map_all_names do
      all.map &:name
    end
  end
end

describe NameUtils do

  before do
    create_mappable_names_model
    populate_mappable_names_table
  end

  after { ModelBuilder.clean }

  subject { MappableName.map_all_names }

  it { is_expected.to match %w(Name0 Name1 Name2) }

  def create_mappable_names_model
    ModelBuilder.build 'MappableName', {
      includes: NameUtils,
      attributes: { name: :string },
      validates: [:name, presence: true]
    }
  end

  def populate_mappable_names_table
    3.times {|i| MappableName.create! name: "Name#{i}" }
  end

end