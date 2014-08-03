require 'database_helper'
require 'active_record/acts_as'

class Product < ActiveRecord::Base
  actable
  belongs_to :store
  validates_presence_of :name, :price

  def present
    "#{name} - $#{price}"
  end

  def raise_error
    specific.non_existant_method
  end
end

class Pen < ActiveRecord::Base
  acts_as :product

  validates_presence_of :color
end

class Store < ActiveRecord::Base
  has_many :products
end

initialize_database do
  create_table :pens do |t|
    t.string :color
  end

  create_table :products do |t|
    t.string :name
    t.float :price
    t.integer :store_id
    t.actable
  end

  create_table :stores do |t|
    t.string :name
  end
end
