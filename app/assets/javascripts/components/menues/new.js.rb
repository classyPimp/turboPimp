module Components
  module Menues
    class New < RW
      expose

      include Plugins::Formable
      ###########
      #PROPS:
      ############
      #parent_menu_item => MenuItem instance to add new MenuItem to
      #on_menu_item_added => passed method from parent that shall be 
      #called when new menu item pushed to parent_menu_item
      #########
      def get_initial_state
        {
          form_model: MenuItem.new 
        }
      end

      def render
        t(:div, {}, 
          input(Forms::Input, state.form_model, :href, {type: "text", value: state.form_model.href}),
          input(Forms::Input, state.form_model, :link_text, {type: "text", value: state.form_model.link_text}),
          t(:button, {onClick: ->{handle_inputs}}, "add menu item")
        )
      end

      def handle_inputs
        collect_inputs
        unless state.form_model.has_errors?
          props.parent_menu_item.menu_items << state.form_model
          clear_inputs
          self.set_state form_model: MenuItem.new
          props.on_menu_item_added(props.parent_menu_item)
        else
          set_state form_model: state.form_model 
        end
      end
    end
  end
end