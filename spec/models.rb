require 'database_helper'
require 'active_record/acts_as'

class Product < ActiveRecord::Base
  actable
end

class Pen < ActiveRecord::Base
  acts_as :product
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
