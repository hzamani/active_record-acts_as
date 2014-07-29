
module ActiveRecord
  module ActsAs
    module Querying
      def where(opts = :chain, *rest)
        if opts.is_a? Hash
          opts, acts_as_opts = opts.partition { |k,v| attribute_names.include?(k.to_s) }.map(&:to_h)
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
end
