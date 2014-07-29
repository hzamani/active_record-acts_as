
module ActiveRecord
  module ActsAs
    module Relation
      extend ActiveSupport::Concern

      module ClassMethods
        def acts_as(name, scope = nil, options = {})
          options, scope = scope, nil if Hash === scope
          options = {as: :actable, dependent: :destroy, validate: false, autosave: true}.merge options

          reflections = has_one name, scope, options
          default_scope -> { eager_load(name) }
          validate :actable_must_be_valid

          cattr_reader(:acting_as_reflection) { reflections[name.to_sym] }
          cattr_reader(:acting_as_name) { name.to_s }
          cattr_reader(:acting_as_model) { name.to_s.camelize.constantize }
          class_eval "def acting_as() #{name} || build_#{name} end"

          include ActsAs::InstanceMethods
          extend  ActsAs::Querying
        end

        def acting_as?(other = nil)
          if respond_to?(:acting_as_reflection) &&
              acting_as_reflection.is_a?(ActiveRecord::Reflection::AssociationReflection)
            other.nil? || acting_as_reflection.name.to_s == other.to_s.underscore
          else
            false
          end
        end

        def is_a?(klass)
          super || acting_as?(klass)
        end

        def actable(options = {})
          name = options.delete(:as) || :actable

          reflections = belongs_to name, {polymorphic: true, dependent: :delete, autosave: true}.merge(options)

          cattr_reader(:actable_reflection) { reflections[name] }

          alias_method :specific, name
        end

        def actable?
          respond_to?(:actable_reflection) &&
            actable_reflection.is_a?(ActiveRecord::Reflection::AssociationReflection)
        end
      end
    end
  end
end
