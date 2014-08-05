
module ActiveRecord
  module QueryMethods
    def where_with_acts_as(opts = :chain, *rest)
      if acting_as? && opts.is_a?(Hash)
        opts, acts_as_opts = opts.stringify_keys.partition { |k,v| attribute_method?(k) }
        opts, acts_as_opts = Hash[opts], Hash[acts_as_opts]
        opts[acting_as_model.table_name] = acts_as_opts unless acts_as_opts.empty?
      end
      where_without_acts_as(opts, *rest)
    end
    alias_method_chain :where, :acts_as
  end

  class Relation
    def scope_for_create_with_acts_as
      @scope_for_create ||= if acting_as?
        where_values_hash.merge(where_values_hash(acting_as_model.table_name)).merge(create_with_value)
      else
        where_values_hash.merge(create_with_value)
      end
    end
    alias_method_chain :scope_for_create, :acts_as
  end
end
