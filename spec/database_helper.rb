require 'active_record'

def connect_to_databse
  ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
end

def clear_database
  ActiveRecord::Base.descendants.each do |model|
    model.delete_all if model.table_exists?
  end
end

def reset_database
  ActiveRecord::Base.descendants.map(&:reset_column_information)
  ActiveRecord::Base.connection.disconnect!
  connect_to_databse
end

def initialize_database(&block)
  reset_database
  ActiveRecord::Schema.define(&block)
end

I18n.enforce_available_locales = false
ActiveRecord::Migration.verbose = false
connect_to_databse
