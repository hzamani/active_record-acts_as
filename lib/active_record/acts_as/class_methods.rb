module ActiveRecord
  module ActsAs
    module ReflectionsWithActsAs
      def _reflections
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

      def actables
        acting_as_model.where(actable_id: select(:id))
      end
    end
  end
end
