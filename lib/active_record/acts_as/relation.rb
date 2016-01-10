module ActiveRecord
  module ActsAs
    module Relation
      extend ActiveSupport::Concern

      module ClassMethods
        def acts_as(name, scope = nil, options = {})
          default_scope -> { includes(name) }

          if scope && scope.is_a?(Hash)
            options = scope
            scope = nil
          end

          options = {
            as: :actable,
            dependent: :destroy,
            validate: false,
            autosave: true
          }.merge options

          cattr_reader(:validates_actable) do
            options.delete(:validates_actable) == false ? false : true
          end

          reflections = has_one name, scope, options
          validate :actable_must_be_valid

          cattr_reader(:acting_as_reflection) { reflections.stringify_keys[name.to_s] }
          cattr_reader(:acting_as_name) { name.to_s }
          cattr_reader(:acting_as_model) do
            (options[:class_name] || name.to_s.camelize).constantize
          end

          class_eval "def acting_as() #{name} || build_#{name} end"
          alias_method :acting_as=, "#{name}=".to_sym

          include ActsAs::InstanceMethods

          singleton_class.module_eval do
            include ActsAs::ClassMethods
          end
        end

        def acting_as?(other = nil)
          if respond_to?(:acting_as_reflection) &&
             acting_as_reflection.is_a?(ActiveRecord::Reflection::AssociationReflection)
            case other
            when Class
              acting_as_reflection.class_name == other.to_s
            when Symbol, String
              acting_as_reflection.class_name.underscore == other.to_s
            when NilClass
              true
            end
          else
            false
          end
        end

        def is_a?(klass)
          super || acting_as?(klass)
        end

        def actable(options = {})
          name = options.delete(:as) || :actable

          reflections = belongs_to name, {
            polymorphic: true,
            dependent: :delete,
            autosave: true
          }.merge(options)

          cattr_reader(:actable_reflection) { reflections.stringify_keys[name.to_s] }

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
