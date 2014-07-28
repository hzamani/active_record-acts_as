
module ActiveRecord
  module ActsAs
    module Relation
      extend ActiveSupport::Concern

      module ClassMethods
        def acts_as(name, scope = nil, options = {})

          options, scope = scope, nil if Hash === scope
          options = {as: :actable, autosave: true}.merge options

          has_one name, scope, options
        end

        def actable
        end
      end
    end
  end
end
