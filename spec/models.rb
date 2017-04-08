require_relative 'database_helper'

require 'active_record/acts_as'

class Product < ActiveRecord::Base
  actable
  belongs_to :store, touch: true
  has_many :buyers, dependent: :destroy
  has_one :payment, as: :payable
  validates_presence_of :name, :price
  store :settings, accessors: [:global_option]

  def self.with_price_higher_than(price)
    where('price > ?', price)
  end

  def self.test_class_method
    'test'
  end

  def present
    "#{name} - $#{price}"
  end

  def raise_error
    specific.non_existant_method
  end
end

class Payment < ActiveRecord::Base
  belongs_to :payable, polymorphic: true
end

class PenCollection < ActiveRecord::Base
  has_many :pens
end

class Pen < ActiveRecord::Base
  acts_as :product
  store_accessor :settings, :option1

  has_many :pen_caps, dependent: :destroy
  belongs_to :pen_collection, touch: true

  validates_presence_of :color

  def pen_instance_method
  end
end

class Buyer < ActiveRecord::Base
  belongs_to :product
end

class PenCap < ActiveRecord::Base
  belongs_to :pen
end

class IsolatedPen < ActiveRecord::Base
  self.table_name = :pens
  acts_as :product, validates_actable: false
  store_accessor :settings, :option2

  validates_presence_of :color
end

class Store < ActiveRecord::Base
  has_many :products
end

module Inventory
  class ProductFeature < ActiveRecord::Base
    self.table_name = 'inventory_product_features'
    actable
    validates_presence_of :name, :price

    def present
      "#{name} - $#{price}"
    end
  end

  class PenLid < ActiveRecord::Base
    self.table_name = 'inventory_pen_lids'
    acts_as :product_feature, class_name: 'Inventory::ProductFeature'

    validates_presence_of :color
  end
end

def initialize_schema
  initialize_database do
    create_table :pen_collections do |t|
      t.timestamps null: true
    end

    create_table :pens do |t|
      t.string :color
      t.integer :pen_collection_id
    end

    create_table :products do |t|
      t.string :name
      t.float :price
      t.integer :store_id
      t.text :settings
      t.timestamps null: true
      t.actable
    end

    create_table :payments do |t|
      t.references :payable, polymorphic: true
      t.timestamps null: true
    end

    create_table :stores do |t|
      t.string :name
      t.timestamps null: true
    end

    create_table :buyers do |t|
      t.integer :product_id
    end

    create_table :pen_caps do |t|
      t.integer :pen_id
    end

    create_table :inventory_pen_lids do |t|
      t.string :color
    end

    create_table :inventory_product_features do |t|
      t.string :name
      t.float :price
      t.actable index: { name: 'index_inventory_product_features_on_actable' }
    end
  end
end

initialize_schema
