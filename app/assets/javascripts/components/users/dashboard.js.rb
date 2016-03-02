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
        t(:div, {className: "row dashboard"},
          t(:div, {className: "col-lg-2 left_panel"},
            if state.current_user.has_role? [:admin] 
              t(:div, {className: 'roles_block'},
                t(:p, {className: 'role_category'}, "actions for admin:"),
                t(:ul, {},
                  t(:li, {onClick: ->{init_user_creation}}, "add users"),
                  t(:li, {onClick: ->{init_users_index} }, "list users"),
                  t(:li, {onClick: ->{init_menues_index_edit}}, "edit menu"),
                  t(:li, {onClick: ->{init_pages_new}}, "create new page"),
                  t(:li, {onClick: ->{init_pages_index}}, "list and search for pages" ),
                  t(:li, {onClick: ->{init_prices_index}}, 'browse and edit price list')
                )
              )
            end,
            if state.current_user.has_role? [:blogger]
              t(:div, {className: 'roles_block'},
                t(:p, {className: 'role_category'}, "actions for blogger"),
                t(:ul, {},
                  t(:li, {onClick: ->{init_components_blogs_new}}, "create new blog post"),
                  t(:li, {onClick: ->{init_blogger_blogs_last_ten}}, "browse my last ten blog posts"),
                  t(:li, {onClick: ->{init_blogs_index}}, "list and search my blogs")
                )
              )
            end,
            if state.current_user.has_role? [:doctor]
              t(:div, {className: 'roles_block'},
                t(:p, {className: 'role_category'}, "actions for doctor"),
                t(:ul, {},
                  t(:li, {onClick: ->{init_doctor_appointments_index}}, "my appointments")
                )
              )
            end,
            if state.current_user.has_role? [:appointment_scheduler]
              t(:div, {className: 'roles_block'},
                t(:p, {className: 'role_category'}, "actions for appointment scheduler"),
                t(:ul, {},
                  t(:li, { onClick: ->{init_appointment_schedulers_appointments_proposal_index} }, "appointments requests"),
                  t(:li, { onClick: ->{ init_appointment_schedulers_appointments_index } }, "browse schedule"),
                  t(:li, { onClick: ->{ init_user_appointment_schedulers_new } }, 'register patient'),
                  t(:li, { onClick: ->{ init_user_appointment_schedulers_index } }, 'manage patients'),
                  t(:li, { onClick: ->{ init_appointment_schedulers_chat_messages_index } }, 'browse chats')
                )
              ) 
            end
          ),
          t(:div, {className: "col-lg-10 content"},
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
        set_state current_control_component: Native(t(Components::Users::Index, {as_admin: true, location: props.location,
                                                                                 history: props.history}))
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

      def init_prices_index
        set_state current_control_component: Native(t(Components::Admin::Prices::Index.create_class))
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
#*******************************    ROLE APPOINTMENT_SCHEDULER

      def init_appointment_schedulers_appointments_proposal_index
        set_state current_control_component: Native(t(Components::Appointments::AppointmentSchedulers::ProposalIndex))
      end

      def init_appointment_schedulers_appointments_index
        set_state current_control_component: Native(t(Components::Appointments::AppointmentSchedulers::Index, {uniq_profiles: {}, date: Moment.new.startOf('day'), from_proposal: false}))
      end

      def init_user_appointment_schedulers_new
        set_state current_control_component: Native(t(Components::AppointmentSchedulers::Users::New))
      end

      def init_user_appointment_schedulers_index
        set_state current_control_component: Native(t(Components::AppointmentSchedulers::Users::Index))
      end

      def init_appointment_schedulers_chat_messages_index
        set_state current_control_component: Native(t(Components::AppointmentSchedulers::ChatMessages::Index))
      end

#*******************************    END ROLE APPOINTMENT_SCHEDULER
    end
  end
end
