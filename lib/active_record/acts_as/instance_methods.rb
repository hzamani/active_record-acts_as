
module ActiveRecord
  module ActsAs
    module InstanceMethods
      def acting_as?(other = nil)
        self.class.acting_as? other
      end

      def is_a?(klass)
        super || acting_as?(klass)
      end

      def actable_must_be_valid
        unless acting_as.valid?
          acting_as.errors.each do |att, message|
            errors.add(att, message)
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
      private :write_attribute

      def attributes
        acting_as.attributes.except(acting_as_reflection.type, acting_as_reflection.foreign_key).merge(super)
      end

      def attribute_names
        super | (acting_as.attribute_names - [acting_as_reflection.type, acting_as_reflection.foreign_key])
      end


      def respond_to?(name, include_private = false)
        super || acting_as.respond_to?(name)
      end

      def dup
        super.acting_as = acting_as.dup
      end

      def method_missing(method, *args, &block)
        if acting_as.respond_to?(method)
          acting_as.send(method, *args, &block)
        else
          super
        end
      end
    end
  end
end
