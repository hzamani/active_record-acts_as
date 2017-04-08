require 'models'

RSpec.describe "ActiveRecord::Base subclass with #actable" do
  subject { Product }

  let(:pen_attributes) { {name: 'pen', price: 0.8, color: 'red'} }
  let(:pen) { Pen.new pen_attributes }

  it "has a polymorphic belongs_to :actable relation" do
    association = subject.reflect_on_all_associations.find { |r| r.name == :actable }
    expect(association).to_not be_nil
    expect(association.macro).to eq(:belongs_to)
    expect(association).to be_polymorphic
  end

  describe "#actable?" do
    it "returns true for actable models" do
      expect(Product.actable?).to be true
    end

    it "returns false for none actable models" do
      expect(Pen.actable?).to be false
    end
  end

  describe "#actable_reflection" do
    it "returns an activerecord assosiation reflection" do
      expect(Product.actable_reflection).to_not be_nil
      expect(Product.actable_reflection).to be_a(ActiveRecord::Reflection::AssociationReflection)
    end
  end

  describe "#specific" do
    context "when a submodel instance exists" do
      it 'returns it' do
        pen.save!
        pen.color = 'cyan'
        expect(pen.acting_as.specific).to eq(pen)
        expect(pen.acting_as.specific.color).to eq('cyan')
      end
    end

    context "when no submodel instance exists" do
      it 'returns nil' do
        expect(subject.new.specific).to be_nil
      end
    end
  end

  it "raises NoMethodError for undefined methods on specific" do
    pen.save
    expect{ pen.product.raise_error }.to raise_error(NoMethodError, /undefined method `non_existant_method' for #<Pen/)
  end

  it "deletes specific subclass on destroy" do
    pen.save
    pen.product.destroy
    expect { pen.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "saves submodel on save" do
    pen.save
    product = pen.acting_as
    product.specific.color = 'blue'
    product.save
    pen.reload
    expect(pen.color).to eq('blue')
  end
end
