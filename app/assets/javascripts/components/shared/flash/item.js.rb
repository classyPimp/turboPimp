module Shared
  module Flash
    class Item < RW
      #PROPS
      #flash_message: Shared::FlashMessage instance REQUIRED

      expose

      def dismiss_button
        t(:button, {className: "close", type: "button", onClick: ->{props.on_close(props.flash_message)}}, 
          "X"
        )
      end

      def render
        t(:div, {className: "alert alert-#{props.flash_message.type}"},
          if props.flash_message.dismissible
            dismiss_button
          end,
          props.flash_message.body
        )
      end

    end
  end
end
