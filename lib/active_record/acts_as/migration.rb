
module ActiveRecord
  module ActsAs
    module Migration
      module TableDefinition
        def actable(options = {})
          name = options.delete(:as) || :actable
          options[:polymorphic] = true
          references(name, options)
        end
      end

      module Table
        def actable(options = {})
          name = options.delete(:as) || :actable
          options[:polymorphic] = true
          @base.add_reference(@table_name, name, options)
        end

        def remove_actable(options = {})
          name = options.delete(:as) || :actable
          options[:polymorphic] = true
          @base.remove_reference(@table_name, name, options)
        end
      end
    end
  end

  module ConnectionAdapters
    class TableDefinition
      include ActsAs::Migration::TableDefinition
    end
  end

  module ConnectionAdapters
    class Table
      include ActsAs::Migration::Table
    end
  end
end
