module ActiveRecord
  module ActsAs
    module Autosave
      def non_cyclic_save(target, &block)
        return if !target || target.saved_state_set?

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
    end
  end
end
