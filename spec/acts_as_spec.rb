require 'models'

RSpec.describe "ActiveRecord::Base model with #acts_as called" do
  subject { Pen }

  let(:pen_attributes) { {name: 'pen', price: 0.8, color: 'red'} }

  it "has a has_one relation" do
    association = subject.reflect_on_all_associations.find { |r| r.name == :product }
    expect(association).to_not be_nil
    expect(association.macro).to eq(:has_one)
    expect(association.options).to have_key(:as)
  end

  describe "#acting_as?" do
    it "returns true for supermodel class and name" do
      expect(Pen.acting_as? :product).to be true
      expect(Pen.acting_as? Product).to be true
    end

    it "returns false for anything other than supermodel" do
      expect(Pen.acting_as? :model).to be false
      expect(Pen.acting_as? String).to be false
    end
  end

  describe "#is_a?" do
    it "responds true when supermodel passed to" do
      expect(Pen.is_a? Product).to be true
      expect(Pen.is_a? Object).to be true
      expect(Pen.is_a? String).to be false
    end
  end

  it "have supermodel attributes accessible on creation" do
    expect{Pen.create(pen_attributes)}.to_not raise_error
  end
end
