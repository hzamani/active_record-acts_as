module ActiveRecord
  module ActsAs
    module ReflectionsWithActsAs
      def _reflections
        @_reflections_acts_as_cache ||=
          super.reverse_merge(acting_as_model._reflections)
      end
    end

    module ClassMethods
      def self.included(module_)
        module_.prepend ReflectionsWithActsAs
      end

      def validators_on(*args)
        super + acting_as_model.validators_on(*args)
      end
    end
  end
end
