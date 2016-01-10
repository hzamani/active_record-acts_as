require 'active_support'
require 'active_record'
require 'active_record/acts_as/version'
require 'active_record/acts_as/relation'
require 'active_record/acts_as/migration'
require 'active_record/acts_as/instance_methods'

if ActiveRecord::VERSION::MAJOR >= 5
  require 'active_record/acts_as/experimental/class_methods'
  require 'active_record/acts_as/experimental/querying'
else
  require 'active_record/acts_as/class_methods'
  require 'active_record/acts_as/querying'
end

module ActiveRecord
  class Base
    include ActsAs::Relation
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
