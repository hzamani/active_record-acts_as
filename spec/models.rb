require 'database_helper'
require 'active_record/acts_as'

class Product < ActiveRecord::Base
  actable
  belongs_to :store
  validates_presence_of :name, :price
  store :settings, accessors: [:global_option]

  def present
    "#{name} - $#{price}"
  end

  def raise_error
    specific.non_existant_method
  end
end

class Pen < ActiveRecord::Base
  acts_as :product
  store_accessor :settings, :option1

  validates_presence_of :color
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
    create_table :pens do |t|
      t.string :color
    end

    create_table :products do |t|
      t.string :name
      t.float :price
      t.integer :store_id
      t.text :settings
      t.timestamps null: true
      t.actable
    end

    create_table :stores do |t|
      t.string :name
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
