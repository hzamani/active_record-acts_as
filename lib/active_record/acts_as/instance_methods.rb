
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

      def respond_to?(name, include_private = false)
        super || acting_as.respond_to?(name)
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
