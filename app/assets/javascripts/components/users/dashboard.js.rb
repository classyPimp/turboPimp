module Components
  module Users
    class Dashboard < RW
      expose

      include Plugins::DependsOnCurrentUser

      def init
        @blank_control_component = ->{Native(t(:div, {}))}
      end

      def get_initial_state
        {
          current_control_component: @blank_control_component
        }
      end

      def render
        t(:div, {className: "row"},
          t(:div, {className: "col-lg-2"},
            if state.current_user.has_role? [:admin] 
              t(:div, {},
                "actions for admin:",
                t(:br, {}),
                t(:button, {onClick: ->{init_user_creation}}, "add users"),
                t(:br, {}),
                t(:button, {onClick: ->{init_users_index} }, "list users"),
                t(:br, {}),
                t(:button, {onClick: ->{init_menues_index_edit}}, "edit menu"),
                t(:br, {}),
                t(:button, {onClick: ->{init_pages_new}}, "create new page"),
                t(:br, {}),
                t(:button, {onClick: ->{init_pages_index}}, "list and search for pages" )
              )
            end,
            if state.current_user.has_role? [:blogger]
              t(:div, {},
                "actions for blogger",
                t(:br, {}),
                t(:button, {onClick: ->{init_components_blogs_new}}, "create new blog post"),
                t(:br, {}),
                t(:button, {onClick: ->{init_blogger_blogs_last_ten}}, "browse my last ten blog posts"),
                t(:br, {}),
                t(:button, {onClick: ->{init_blogs_index}}, "list and search my blogs")
              )
            end,
            if state.current_user.has_role? [:doctor]
              t(:div, {},
                "actions for doctor",
                t(:br, {}),
                t(:button, {onClick: ->{init_doctor_appointments_index}}, "appointments")
              )
            end
          ),
          t(:div, {className: "col-lg-10"},
            state.current_control_component.to_n
          )
        ) 
      end
#*********************************      #ROle admin
      def init_user_creation
        set_state current_control_component: Native(t(Components::Users::New, {on_create: ->(user){on_user_added(user)}, as_admin: true}))
      end
      #role admin
      def init_users_index
        set_state current_control_component: Native(t(Components::Users::Index, {as_admin: true}))
      end

      def init_menues_index_edit
        set_state current_control_component: Native(t(Components::Menues::IndexEdit, {}))
      end
      #role admin
      def on_user_added(user)
        msg = Shared::Flash::Message.new(t(:div, {}, link_to("user created press here to show", "/users/show/#{user.id}")), "success")
        Components::App::Main.instance.ref(:flash).rb.add_message(msg)
        set_state current_control_component: @blank_control_component
      end

      def init_pages_new
        set_state current_control_component: Native(t(Components::Pages::New, {as_admin: true}))
      end

      def init_pages_index
        set_state current_control_component: Native(t(Components::Pages::Index, {as_admin: true, location: props.location,
                                                                                 history: props.history}))
      end

      


#*******************************    END ROLE ADMIN
#*******************************    ROLE BLOGGER
      
      def init_components_blogs_new
        set_state current_control_component: Native(t(Components::Blogs::New, {}))
      end

      def init_blogger_blogs_last_ten
        set_state current_control_component: Native(t(Components::Blogger::Blogs::LastTen, {}))
      end

      def init_blogs_index
        set_state current_control_component: Native(t(Components::Blogs::Index, {as_blogger: true, location: props.location,
                                                                                 history: props.history}))
      end
  
#*******************************    END ROLE BLOGGER
#*******************************    ROLE DOCTOR
      
      def init_doctor_appointments_index
        set_state current_control_component: Native(t(Components::Appointments::Doctors::Index))
      end

#*******************************    END ROLE DOCTOR
    end
  end
end
