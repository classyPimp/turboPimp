module Components
  module Dashboards
    class Admin < RW
      expose

      def insitial_state
        {
          current_control_component: false
        }
      end

      def render
        t(:div, {}, 
          t(:div, {className: "row"},
            t(:button, {onClick: ->(){init_user_creation}}, "add users")
          ),
          t(:div, {className: "row"},
            t(:div, {className: "container"},)
          )
        ) 
      end

      def init_user_creation
        set_state current_control_component: t(Components::Users::New, {})
      end

    end
  end
end