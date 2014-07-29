
module ActiveRecord
  module ActsAs
    module InstanceMethods
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
