module ActiveRecord
  module ScopeForCreateWithActAs
    def scope_for_create
      @scope_for_create ||= if acting_as?
                              where_values_hash.merge(where_values_hash(acting_as_model.table_name)).merge(create_with_value)
                            else
                              where_values_hash.merge(create_with_value)
                            end
    end
  end

  module WhereWithActAs
    def where(opts = :chain, *rest)
      if acting_as? && opts.is_a?(Hash)
        opts, acts_as_opts = opts.stringify_keys.partition { |k, _v| attribute_method?(k) }
        opts = Hash[opts]
        acts_as_opts = Hash[acts_as_opts]
        opts[acting_as_model.table_name] = acts_as_opts unless acts_as_opts.empty?
      end
      where_without_acts_as(opts, *rest)
    end
  end

  class Relation
    prepend ScopeForCreateWithActAs
  end

  module QueryMethods
    prepend WhereWithActAs
  end
end
