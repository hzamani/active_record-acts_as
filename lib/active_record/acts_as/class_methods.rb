module ActiveRecord
  module ActsAs
    module ClassMethods
      def self.included(module_)
        module_.alias_method_chain :_reflections, :acts_as
      end

      def _reflections_with_acts_as
        @_reflections_acts_as_cache ||=
          _reflections_without_acts_as.reverse_merge(acting_as_model._reflections)
      end

      def validators_on(*args)
        super + acting_as_model.validators_on(*args)
      end
    end
  end
end
