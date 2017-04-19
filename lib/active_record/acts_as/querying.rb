module ActiveRecord
  module ActsAs
    module QueryMethods
      def where!(opts, *)
        if acting_as? && opts.is_a?(Hash)
          if table_name_opts = opts.delete(klass.table_name)
            opts = opts.merge(table_name_opts)
          end

          # Filter out the conditions that should be
          # applied to the `acting_as_model`. Ignore
          # conditions that contain a dot or are attributes
          # of the submodel.
          opts, acts_as_opts = opts.stringify_keys.partition { |k, _| k =~ /\./ || column_names.include?(k.to_s) }.map(&:to_h)

          if acts_as_opts.any?
            opts[acting_as_model.table_name] = acts_as_opts
          end
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
