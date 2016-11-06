module ActiveRecord
  module ActsAs
    module InstanceMethods
      def acting_as?(other = nil)
        self.class.acting_as? other
      end

      def is_a?(klass)
        super || acting_as?(klass)
      end

      def acting_as_foreign_key
        acting_as[acting_as_reflection.foreign_key]
      end

      # Is the superclass persisted to the database?
      def acting_as_persisted?
        return false if acting_as.nil?
        !acting_as.id.nil? && !acting_as_foreign_key.nil?
      end

      def touch_actable
        return unless changed?
        acting_as.touch
      end

      def actable_must_be_valid
        if validates_actable
          unless acting_as.valid?
            acting_as.errors.each do |att, message|
              errors.add(att, message)
            end
          end
        end
      end
      protected :actable_must_be_valid

      def read_attribute(attr_name, *args, &block)
        if attribute_method?(attr_name.to_s)
          super
        else
          acting_as.read_attribute(attr_name, *args, &block)
        end
      end

      def write_attribute(attr_name, value, *args, &block)
        if attribute_method?(attr_name.to_s)
          super
        else
          acting_as.send(:write_attribute, attr_name, value, *args, &block)
        end
      end

      def read_store_attribute(store_attribute, key)
        if attribute_method?(store_attribute.to_s)
          super
        else
          acting_as.read_store_attribute(store_attribute, key)
        end
      end

      def write_store_attribute(store_attribute, key, value)
        if attribute_method?(store_attribute.to_s)
          super
        else
          acting_as.send(:write_store_attribute, store_attribute, key, value)
        end
      end
      private :write_attribute, :write_store_attribute

      def attributes
        acting_as_persisted? ? acting_as.attributes.except(acting_as_reflection.type, acting_as_reflection.foreign_key).merge(super) : super
      end

      def attribute_names
        acting_as_persisted? ? super | (acting_as.attribute_names - [acting_as_reflection.type, acting_as_reflection.foreign_key]) : super
      end

      def has_attribute?(attr_name, as_original_class = false)
        if as_original_class
          super(attr_name)
        else
          super(attr_name) || acting_as.has_attribute?(attr_name)
        end
      end

      def column_for_attribute(name)
        if has_attribute?(name, true)
          super(name)
        else
          acting_as.column_for_attribute(name)
        end
      end

      def touch
        acting_as.touch
      end

      def respond_to?(name, include_private = false, as_original_class = false)
        as_original_class ? super(name, include_private) : super(name, include_private) || acting_as.respond_to?(name)
      end

      def self_respond_to?(name, include_private = false)
        respond_to? name, include_private, true
      end

      def dup
        duplicate = super
        duplicate.acting_as = acting_as.dup
        duplicate
      end

      def method_missing(method, *args, &block)
        uses_superclass_for?(method) ? acting_as.send(method, *args, &block) : super
      end

      def uses_superclass_for?(method)
        responds_locally = self_respond_to?(method)
        if acting_as.respond_to?(method)
          if responds_locally
            false
          else
            # Only use getters if the superclass has
            # an instance that is linked to this class instance.
            if acting_as_persisted?
              true
            else
              responds_locally ? false : true
            end
          end
        else
          # If the superclass doesn't have it, use this class's methods
          false
        end
      end
    end
  end
end
