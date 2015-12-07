module Components
  module Dashboards
    class Admin < RW
      
      expose

      def get_initial_state
        {
          current_control_component: Native(t(:div, {}, "nothing"))
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
        set_state current_control_component: Native(t(Users::New, {}))
      end

    end
  end
end