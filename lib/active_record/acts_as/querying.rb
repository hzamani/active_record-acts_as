
module ActiveRecord
  module ActsAs
    module Querying
      def where(opts = :chain, *rest)
        if opts.is_a? Hash
          opts, acts_as_opts = opts.partition { |k,v| attribute_names.include?(k.to_s) }
          opts, acts_as_opts = Hash[opts], Hash[acts_as_opts]
          opts[acting_as_model.table_name] = acts_as_opts
        end
        super(opts, *rest)
      end

      def find_by(*args)
        where(*args).take
      end

      def find_by!(*args)
        where(*args).take!
      end
    end
  end

  class Relation
    alias_method :scope_for_create_without_acting_as, :scope_for_create

    def scope_for_create
      @scope_for_create ||= if acting_as?
        where_values_hash.merge(where_values_hash(acting_as_model.table_name)).merge(create_with_value)
      else
        where_values_hash.merge(create_with_value)
      end
    end
  end
end
