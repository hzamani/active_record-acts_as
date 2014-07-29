
module ActiveRecord
  module ActsAs
    module Relation
      extend ActiveSupport::Concern

      module ClassMethods
        def acts_as(name, scope = nil, options = {})
          options, scope = scope, nil if Hash === scope
          options = {as: :actable, autosave: true}.merge options

          has_one name, scope, options

          cattr_reader(:acting_as) { name.to_s }
        end

        def acting_as?(other = nil)
          if respond_to? :acting_as
            other.nil? || (acting_as && acting_as == other.to_s.underscore)
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
