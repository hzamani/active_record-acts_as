module ActiveRecord
  module ActsAs
    module Autosave
      def self.included(base)
        base.class_eval do
          # Rails 5 has an issue that after_update callback gets called for new records. The below callbacks ensures
          # that `non_cyclic_save` is not called in such cases.
          before_create do
            @_was_new_record = true
            true
          end

          after_rollback do
            @_was_new_record = nil
          end

          after_commit do
            @_was_new_record = nil
          end
        end
      end

      def non_cyclic_save(target, &block)
        return if !target || target.saved_state_set? || was_new_record?

        @_saved_state = true
        target.instance_variable_set(:@_saved_state, true)
        yield
        target.instance_variable_set(:@_saved_state, false)
        @_saved_state = false
      end
      private :non_cyclic_save

      def saved_state_set?
        defined?(@_saved_state) ? @_saved_state : false
      end

      def was_new_record?
        !!@_was_new_record
      end
      private :was_new_record?
    end
  end
end
