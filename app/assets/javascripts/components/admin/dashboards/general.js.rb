module Components
  module Admin
    module Dashboards
      class General < RW
        
        expose

        def get_initial_state
          @blank_control_component = ->{t(:div, {})}
          {
            current_control_component: @blank_control_component
          }
        end

        def render
          t(:div, {}, 
            t(:div, {className: "row"},
              t(:button, {onClick: ->{init_user_creation}}, "add users"),
              t(:button, {onClick: ->{init_users_index} }, "list users")
            ),
            t(:div, {className: "row"},
              t(:div, {className: "container"},
                state.current_control_component
              )
            )
          ) 
        end

        def init_user_creation
          set_state current_control_component: Native(t(Components::Users::New, {on_create: ->(user){on_user_added(user)}, as_admin: true}))
        end

        def init_users_index
          set_state current_control_component: Native(t(Components::Users::Index, {namespace: 'admin'}))
        end

        def on_user_added(user)
          msg = Shared::Flash::Message.new(t(:div, {}, link_to("user created press here to show", "/users/show/#{user.id}")), "success")
          Components::App::Main.instance.ref(:flash).rb.add_message(msg)
          set_state current_control_component: @blank_control_component
        end

      end
    end
  end
end