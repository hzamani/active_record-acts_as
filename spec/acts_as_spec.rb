require 'models'

RSpec.describe "ActiveRecord::Base model with #acts_as called" do
  subject { Pen }

  let(:pen_attributes) { {name: 'pen', price: 0.8, color: 'red'} }
  let(:pen) { Pen.new pen_attributes }
  let(:store) { Store.new name: 'biggerman' }

  it "has a has_one relation" do
    association = subject.reflect_on_all_associations.find { |r| r.name == :product }
    expect(association).to_not be_nil
    expect(association.macro).to eq(:has_one)
    expect(association.options).to have_key(:as)
  end

  it "has a cattr_reader for the acting_as_model" do
    expect(subject.acting_as_model).to eq Product
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

  describe ".acting_as?" do
    it "returns true for supermodel class and name" do
      expect(pen.acting_as? :product).to be true
      expect(pen.acting_as? Product).to be true
    end

    it "returns false for anything other than supermodel" do
      expect(pen.acting_as? :model).to be false
      expect(pen.acting_as? String).to be false
    end
  end

  describe "#is_a?" do
    it "responds true when supermodel passed to" do
      expect(Pen.is_a? Product).to be true
      expect(Pen.is_a? Object).to be true
      expect(Pen.is_a? String).to be false
    end
  end

  describe ".is_a?" do
    it "responds true when supermodel passed to" do
      expect(pen.is_a? Product).to be true
      expect(pen.is_a? Object).to be true
      expect(pen.is_a? String).to be false
    end
  end

  describe "#acting_as_name" do
    it "return acts_as model name" do
      expect(pen.acting_as_name).to eq('product')
    end
  end

  describe "#acting_as" do
    it "returns autobuilded acts_as model" do
      expect(pen.acting_as).to_not be_nil
      expect(pen.acting_as).to be_instance_of(Product)
    end
  end

  describe "#acting_as=" do
    it "sets acts_as model" do
      product = Product.new(name: 'new product', price: 0.99)
      pen = Pen.new
      pen.acting_as = product
      expect(pen.acting_as).to eq(product)
    end
  end

  describe "#dup" do
    it "duplicates actable model as well" do
      p = pen.dup
      expect(p.name).to eq('pen')
      expect(p.price).to eq(0.8)
    end
  end

  it "have supermodel attributes accessible on creation" do
    expect{Pen.create(pen_attributes)}.to_not raise_error
  end

  context "instance" do
    it "responds to supermodel methods" do
      %w(name name= name? name_change name_changed? name_was name_will_change! price color).each do |name|
        expect(pen).to respond_to(name)
      end
      expect(pen.present).to eq("pen - $0.8")
    end

    it "saves supermodel attributes on save" do
      pen.save
      pen.reload
      expect(pen.name).to eq('pen')
      expect(pen.price).to eq(0.8)
      expect(pen.color).to eq('red')
    end

    it "raises NoMethodEror on unexisting method call" do
      expect { pen.unexisted_method }.to raise_error(NoMethodError)
    end

    it "destroies Supermodel on destroy" do
      pen.save
      product_id = pen.product.id
      pen.destroy
      expect { Product.find(product_id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "validates supermodel attribures upon validation" do
      p = Pen.new
      expect(p).to be_invalid
      expect(p.errors.keys).to include(:name, :price, :color)
      p.name = 'testing'
      expect(p).to be_invalid
      p.color = 'red'
      expect(p).to be_invalid
      p.price = 0.8
      expect(p).to be_valid
    end

    it "can set assosications defined in supermodel" do
      store.save
      pen.store = store
      pen.save
      pen.reload
      expect(pen.store).to eq(store)
      expect(pen.product.store).to eq(store)
    end

    it "should be appendable in an has_many relation using << operator" do
      store.save
      store.products << pen
      expect(pen.store).to eq(store)
    end

    it "includes supermodel attributes in .to_json responce" do
      expect(pen.to_json).to eq('{"id":null,"name":"pen","price":0.8,"store_id":null,"color":"red"}')
    end

    it "includes supermodel attribute names in .attribute_names responce" do
      expect(pen.attribute_names).to include("id", "color", "name", "price", "store_id")
    end
  end

  context "Querying" do
    before(:each) { clear_database }

    it "respects supermodel attributes in .where" do
      red_pen = Pen.create(name: 'red pen', price: 0.8, color: 'red')
      blue_pen = Pen.create(name: 'blue pen', price: 0.8, color: 'blue')
      black_pen = Pen.create(name: 'black pen', price: 0.9, color: 'black')

      expect{Pen.where(price: 0.8)}.to_not raise_error
      expect(Pen.where(price: 0.8)).to include(red_pen, blue_pen)
      expect(Pen.where(price: 0.8)).to_not include(black_pen)
    end

    it "respects supermodel attributes in .find_by" do
      red_pen = Pen.create(name: 'red pen', price: 0.8, color: 'red')
      blue_pen = Pen.create(name: 'blue pen', price: 0.8, color: 'blue')
      black_pen = Pen.create(name: 'black pen', price: 0.9, color: 'black')

      expect(Pen.find_by(name: 'red pen')).to eq(red_pen)
      expect(Pen.find_by(name: 'blue pen')).to eq(blue_pen)
      expect(Pen.find_by(name: 'black pen')).to eq(black_pen)
    end

    it "includes supermodel attributes in Relation.scope_for_create" do
      relation = Pen.where(name: 'new name', price: 1.4, color: 'red')
      expect(relation.scope_for_create.keys).to include('name')
      expect(relation.scope_for_create['name']).to eq('new name')
    end
  end

  context 'Namespaces' do
    subject { Inventory::PenLid }

    it "has a has_one relation" do
      association = subject.reflect_on_all_associations.find { |r| r.name == :product_feature }
      expect(association).to_not be_nil
      expect(association.macro).to eq(:has_one)
      expect(association.options).to have_key(:as)
    end

    it "has a cattr_reader for the acting_as_model" do
      expect(subject.acting_as_model).to eq Inventory::ProductFeature
    end
  end
end
