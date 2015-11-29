module Components
  module Menues
    class Edit < RW
      expose
      include Plugins::Formable

      #PROPS
      #menu_item_to_edit => MenuItem instance
      def initial_state
        {
          form_model: props.menu_item_to_edit
        }
      end

      def render
        t(:div, {}, 
          input(Forms::Input, state.form_model, :href, {type: "text"}),
          input(Forms::Input, state.form_model, :link_text, {type: "text"}),
          t(:button, {onClick: ->{handle_inputs}}, "update!")
        )
      end

      def handle_inputs
        collect_inputs
        unless state.form_model.has_errors?
          set_state form_model: props.menu_item_to_edit
          props.on_menu_item_edited(state.form_model)
        else
          set_state form_model: state.form_model 
        end
      end
    
    end
  end
end