require 'spec_helper'
require 'support/dummy_module'

describe ModelBuilder::ClassBuilder do

  let(:builder) { ModelBuilder::ClassBuilder }
  let(:name) { 'ClassBuilderTest' }
  let(:constant) { Object.const_get name }
  let(:options) {{
    superclass: Array,
    includes: [Spec::Support::DummyModule],
    accessors: %w(a1 a2)
  }}

  before { @build_result = builder.build name, options }

  after { ModelBuilder::ClassBuilder.clean }

  describe '.build' do

    subject { @build_result }

    it { is_expected.to eq constant }
    it { expect(builder.dynamic_classes.values).to include constant }

    context 'module validations' do
      let(:name) { 'ModelBuilder::ClassBuilderTest' }

      it { is_expected.to eq ModelBuilder.const_get(name) }
    end

    context 'includes validations' do

      before { subject }

      it { expect(constant.new).to respond_to :dummy_method }

    end

    context 'accessors validations' do

      before { subject }

      it { expect(constant.new).to respond_to :a1 }
      it { expect(constant.new).to respond_to :a2 }
      it { expect(constant.new).to_not respond_to :a3 }

      it { expect(constant.new).to respond_to :a1= }
      it { expect(constant.new).to respond_to :a2= }
      it { expect(constant.new).to_not respond_to :a3= }

    end

  end

  describe '.clean' do

    it { expect{constant}.to_not raise_error }

    context 'after build' do

      before { builder.clean }

      it { expect{constant}.to raise_error(NameError, "uninitialized constant #{name}") }
      it { expect(builder.dynamic_classes.empty?).to be true }

    end

  end

end