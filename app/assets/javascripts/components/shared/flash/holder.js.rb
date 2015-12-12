module Shared
  module Flash
    class Holder < RW
    
      expose
      #PROPS
      # NO PROPS
      
      def get_initial_state
        {
          flash_messages: []
        }
      end

      def render
        t(:div, {className: "flash_holder"},
          *splat_each(state.flash_messages) do |msg|
            t(Shared::Flash::Item, {flash_message: msg, on_close: ->(_msg){close_message(_msg)}})
          end
        )
      end

      def close_message(msg)
        state.flash_messages.delete(msg)
        set_state flash_messages: state.flash_messages
      end

      def add_message(msg)
        state.flash_messages << msg
        set_state flash_messages: state.flash_messages
      end

    end
  end
end
