module ActiveRecord
  module ActsAs
    module QueryMethods
      def where(opts = :chain, *rest)
        if acting_as? && opts.is_a?(Hash)
          opts = opts.merge(opts.delete(klass.table_name) || {})

          opts, acts_as_opts = opts.stringify_keys.partition { |k,v| attribute_method?(k) }
          opts, acts_as_opts = Hash[opts], Hash[acts_as_opts]
          opts[acting_as_model.table_name] = acts_as_opts unless acts_as_opts.empty?
        end

        super
      end
    end

    module ScopeForCreate
      def scope_for_create
        @scope_for_create ||= if acting_as?
          where_values_hash.merge(where_values_hash(acting_as_model.table_name)).merge(create_with_value)
        else
          where_values_hash.merge(create_with_value)
        end
      end
    end
  end

  Relation.send(:prepend, ActsAs::QueryMethods)
  Relation.send(:prepend, ActsAs::ScopeForCreate)
end
