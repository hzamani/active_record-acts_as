module ActiveRecord
  module ActsAs
    module Relation
      extend ActiveSupport::Concern

      module ClassMethods
        def acts_as(name, scope = nil, options = {})
          options, scope = scope, nil if Hash === scope

          association_method = options.delete(:association_method)
          touch              = options.delete(:touch)
          as                 = options.delete(:as) || :actable
          validates_actable  = !options.key?(:validates_actable) || options.delete(:validates_actable)

          options = options.reverse_merge(as: as, validate: false, autosave: true, inverse_of: as)

          reflections = has_one(name, scope, **options)
          default_scope -> {
            case association_method
              when :eager_load
                eager_load(name)
              when :joins
                joins(name)
              else
                includes(name)
            end
          }
          validate :actable_must_be_valid if validates_actable

          unless touch == false
            after_update :touch, if: ActiveRecord.version.to_s.to_f >= 5.1 ? :saved_changes? : :changed?
          end

          before_save do
            @_acting_as_changed = ActiveRecord.version.to_s.to_f >= 5.1 ? acting_as.has_changes_to_save? : acting_as.changed?
            true
          end
          after_commit do
            @_acting_as_changed = nil
          end
          # Workaround for https://github.com/rails/rails/issues/13609
          after_destroy do
            acting_as.destroy if acting_as && !acting_as.destroyed?
          end

          cattr_reader(:acting_as_reflection) { reflections.stringify_keys[name.to_s] }
          cattr_reader(:acting_as_name) { name.to_s }
          cattr_reader(:acting_as_model) { (options[:class_name] || name.to_s.camelize).constantize }
          class_eval "def #{name}; super || build_#{name}(acting_as_model.actable_reflection.name => self); end"
          alias_method :acting_as, name
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

        def actable(scope = nil, **options)
          name = options.delete(:as) || :actable

          reflections = belongs_to(name, scope, **options.reverse_merge(validate: false,
                                                                      polymorphic: true,
                                                                      dependent: :destroy,
                                                                      autosave: true,
                                                                      inverse_of: to_s.underscore))

          cattr_reader(:actable_reflection) { reflections.stringify_keys[name.to_s] }

          def self.methods_callable_by_submodel
            @methods_callable_by_submodel ||= Set.new
          end

          def self.callable_by_submodel(method)
            @methods_callable_by_submodel ||= Set.new
            @methods_callable_by_submodel << method
          end

          def self.scope(*)
            super.tap(&method(:callable_by_submodel))
          end

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
