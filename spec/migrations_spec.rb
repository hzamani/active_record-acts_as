require 'database_helper'
require 'active_record/acts_as'


class Product < ActiveRecord::Base
end

class RemoveActableFromProducts < ActiveRecord::Migration
  def change
    change_table(:products) do |t|
      t.remove_actable
    end
  end
end

class RemoveProduceableFromProducts < ActiveRecord::Migration
  def change
    change_table(:products) do |t|
      t.remove_actable(as: :produceable)
    end
  end
end

RSpec.describe ".actable" do
  context "in .create_table block" do
    after { initialize_schema }
    context "with :as options" do
      it "creates polymorphic reference columns with given name" do
        initialize_database { create_table(:products) { |t| t.actable(as: :produceable) } }
        expect(Product.column_names).to include('produceable_id', 'produceable_type')
      end
    end

    context "with no args" do
      it "creates polymorphic reference columns" do
        initialize_database { create_table(:products) { |t| t.actable } }
        expect(Product.column_names).to include('actable_id', 'actable_type')
      end
    end
  end
end

RSpec.describe ".remove_actable" do
  context "in .modify_table block" do
    after { initialize_schema }

    context "with :as options" do
      before do
        initialize_database do
          create_table(:products) do |t|
            t.string :name
            t.actable(as: :produceable)
          end
        end
      end
      it "removes polymorphic reference columns with given name" do
        mig = RemoveProduceableFromProducts.new
        mig.exec_migration(ActiveRecord::Base.connection, :up)
        Product.reset_column_information
        expect(Product.column_names).not_to include('produceable_id', 'produceable_type')
      end
    end

    context "with no args" do
      before do
        initialize_database do
          create_table(:products) do |t|
            t.string :name
            t.actable
          end
        end
      end
      it "creates polymorphic reference columns" do
        mig = RemoveActableFromProducts.new
        mig.exec_migration(ActiveRecord::Base.connection, :up)
        Product.reset_column_information
        expect(Product.column_names).not_to include('actable_id', 'actable_type')
      end
    end
  end
end
