module Components
  module Dashboards
    class Admin < RW
      
      expose

      def get_initial_state
        @blank_control_component = ->{Native(t(:div, {}))}
        {
          current_control_component: @blank_control_component
        }
      end

      def render
        t(:div, {}, 
          t(:div, {className: "row"},
            t(:button, {onClick: ->(){init_user_creation}}, "add users")
          ),
          t(:div, {className: "row"},
            t(:div, {className: "container"},
              state.current_control_component.to_n
            )
          )
        ) 
      end

      def init_user_creation
        set_state current_control_component: Native(t(Components::Users::New, {on_create: ->(user){on_user_added(user)}}))
      end

      def on_user_added(user)
        alert "foo"
        alert user.pure_attributes
        set_state current_control_component: @blank_control_component
      end

    end
  end
end