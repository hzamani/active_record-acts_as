require 'database_helper'
require 'active_record/acts_as'


class Product < ActiveRecord::Base
end


RSpec.describe ".actable" do
  context "in .create_table block" do
    context "with :as options" do
      it "creates plymorphic reference columns with given name" do
        initialize_database { create_table(:products) { |t| t.actable(as: :produceable) } }
        expect(Product.column_names).to include('produceable_id', 'produceable_type')
      end
    end

    context "with no args" do
      it "creates plymorphic reference columns" do
        initialize_database { create_table(:products) { |t| t.actable } }
        expect(Product.column_names).to include('actable_id', 'actable_type')
      end
    end
  end
end
