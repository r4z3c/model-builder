require 'spec_helper'
require 'support/database_connection'

Spec::Support::DatabaseConnection.establish_sqlite_connection

describe ModelBuilder do

  let(:builder) { ModelBuilder }
  let(:name) { 'TestModel' }
  let(:constant) { name.constantize }
  let(:default_age) { 17 }
  let(:options) do
    {
      attributes: {
        name: :string,
        age: {
          type: :integer,
          default: default_age
        }
      },
      validates: [
        [:name, :age, presence: true],
        [:age, numericality: true]
      ]
    }
  end

  subject { builder.build name, options }

  it { is_expected.to eq constant }
  it { expect(builder.list).to include constant }

  context 'options validations' do

    before { subject }

    subject(:instance) { constant.new }

    context 'attributes validations' do

      it { is_expected.to respond_to :name }
      it { is_expected.to respond_to :age }

      it { is_expected.to respond_to :name= }
      it { is_expected.to respond_to :age= }

      it { expect(instance.age).to eq default_age }

    end

    context 'validations validations' do

      before do
        instance.age = 'noop'
        instance.valid?
      end

      it { expect(instance.valid?).to be false }
      it { expect(instance.errors.messages.keys).to include :name }
      it { expect(instance.errors.messages.keys).to include :age }

    end

  end

  after(:all) { ModelBuilder.clean }

end