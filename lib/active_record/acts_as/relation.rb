
module ActiveRecord
  module ActsAs
    module Relation
      extend ActiveSupport::Concern

      module ClassMethods
        def acts_as(name, scope = nil, options = {})
          options, scope = scope, nil if Hash === scope
          options = {as: :actable, autosave: true}.merge options

          has_one name, scope, options

          cattr_reader(:acting_as_name) { name.to_s }

          class_eval "def acting_as() #{name} || build_#{name} end"

          include ActsAs::InstanceMethods
        end

        def acting_as?(other = nil)
          if respond_to? :acting_as_name
            other.nil? || acting_as_name == other.to_s.underscore
          else
            false
          end
        end

        def is_a?(klass)
          super || acting_as?(klass)
        end

        def actable
        end
      end
    end
  end
end
