require 'spec_helper'

describe ModelBuilder::ClassBuilder do

  let(:builder) { ModelBuilder::ClassBuilder }
  let(:name) { 'ClassBuilderTest' }
  let(:options) { { superclass: Array, accessors: %w(a1 a2) } }
  let(:constant) { Object.const_get name }

  before { @build_result = builder.build name, options }
  after { ModelBuilder::ClassBuilder.clean }

  describe '.build' do

    subject { @build_result }

    it do
      is_expected.to eq constant
    end
    it { expect(builder.list).to include constant }

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

    end

  end

end