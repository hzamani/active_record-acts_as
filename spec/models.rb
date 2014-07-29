require 'database_helper'
require 'active_record/acts_as'

class Product < ActiveRecord::Base
  actable

  validates_presence_of :name, :price

  def present
    "#{name} - $#{price}"
  end
end

class Pen < ActiveRecord::Base
  acts_as :product

  validates_presence_of :color
end

initialize_database do
  create_table :pens do |t|
    t.string :color
  end

  create_table :products do |t|
    t.string :name
    t.float :price
    t.actable
  end
end
