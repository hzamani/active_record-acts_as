module ActiveRecord
  module ActsAs
    module ReflectionsWithActAs
      def _reflections
        @_reflections_acts_as_cache ||=
          super.reverse_merge(acting_as_model._reflections)
      end

      def _reflect_on_association(table_name)
        case table_name
        when String then
          super(table_name) || super(table_name.singularize.to_sym)
        else
          super(table_name)
        end
      end

      def clear_reflections_cache
        @_reflections_acts_as_cache = nil
        super
      end
    end

    module ClassMethods
      def self.included(mod)
        mod.prepend ReflectionsWithActAs
      end

      def validators_on(*args)
        super + acting_as_model.validators_on(*args)
      end
    end
  end
end
