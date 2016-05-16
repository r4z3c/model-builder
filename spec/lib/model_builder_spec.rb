require 'spec_helper'
require 'support/database_connection'
require 'support/dummy_module'

Spec::Support::DatabaseConnection.establish_sqlite_connection

describe ModelBuilder do

  let(:builder) { ModelBuilder }
  let(:name) { 'TestModel' }
  let(:constant) { name.constantize }
  let(:default_age) { 17 }
  let(:options) do
    {
      includes: [Spec::Support::DummyModule],
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

  before { @build_result = builder.build name, options }

  after(:all) { ModelBuilder.clean }

  describe '.build' do

    subject { @build_result }

    it { is_expected.to eq constant }
    it { expect(builder.dynamic_models).to include name }

    context 'module validations' do
      let(:name) { 'ModelBuilder::TestModel' }

      it { is_expected.to eq ModelBuilder.const_get(name) }
    end

    context 'options validations' do

      before { subject }

      subject(:instance) { constant.new }

      context 'includes validations' do

        it { expect(instance).to respond_to :dummy_method }

      end

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

  end

  describe '.clean' do

    it { expect(constant.all.count).to eq 0 }

  end

end