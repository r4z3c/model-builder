require 'spec_helper'

describe ModelBuilder::ClassBuilder do

  let(:builder) { ModelBuilder::ClassBuilder }
  let(:name) { 'ClassBuilderTest' }
  let(:options) { { superclass: Array, accessors: %w(a1 a2) } }
  let(:constant) { name.constantize }

  subject { builder.build name, options }

  it { is_expected.to eq constant }
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