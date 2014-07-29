
module ActiveRecord
  module ActsAs
    module Relation
      extend ActiveSupport::Concern

      module ClassMethods
        def acts_as(name, scope = nil, options = {})
          options, scope = scope, nil if Hash === scope
          options = {as: :actable, dependent: :destroy, validate: false, autosave: true}.merge options

          has_one name, scope, options
          default_scope -> { eager_load(name) }
          validate :actable_must_be_valid

          cattr_reader(:acting_as_name) { name.to_s }
          cattr_reader(:acting_as_model) { name.to_s.camelize.constantize }
          class_eval "def acting_as() #{name} || build_#{name} end"

          include ActsAs::InstanceMethods
          extend  ActsAs::Querying
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
