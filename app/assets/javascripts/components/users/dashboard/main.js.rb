module Components
  module Users
    module Dashboard
      class Main < RW

        include Plugins::DependsOnCurrentUser

        def render
          t(:div, {className: "row dashboard"},
            t(:div, {className: "col-lg-2 left_panel"},
              if state.current_user.has_role? [:admin] 
                t(:div, {className: 'roles_block'},
                  t(:p, {className: 'role_category'}, "actions for admin:"),
                  t(:ul, {},
                    link_to('', '/users/dashboard/new_user') do
                      t(:li, {}, 'create new user')
                    end,
                    link_to('', '/users/dashboard/users_index') do
                      t(:li, {}, "list users")  
                    end,
                    link_to('', '/users/dashboard/edit_menu') do
                      t(:li, {}, "edit menu")
                    end,
                    link_to('', '/users/dashboard/create_page') do
                      t(:li, {}, "create new page")  
                    end,
                    link_to('', '/users/dashboard/pages_index') do
                      t(:li, {}, "list and search for pages" )  
                    end,
                    link_to('', '/users/dashboard/edit_price_list') do
                      t(:li, {}, 'browse and edit price list')  
                    end
                  )
                )
              end,
              if state.current_user.has_role? [:blogger]
                t(:div, {className: 'roles_block'},
                  t(:p, {className: 'role_category'}, "actions for blogger"),
                  t(:ul, {},
                    link_to('', '/users/dashboard/create_blog') do
                      t(:li, {}, "create new blog post")  
                    end,
                    link_to('', '/users/dashboard/last_blogs') do
                      t(:li, {}, "browse my last ten blog posts")  
                    end,
                    link_to('', '/users/dashboard/blogs_index') do
                      t(:li, {}, "list and search my blogs")
                    end
                  )
                )
              end,
              if state.current_user.has_role? [:doctor]
                t(:div, {className: 'roles_block'},
                  t(:p, {className: 'role_category'}, "actions for doctor"),
                  t(:ul, {},
                    link_to('', '/users/dashboard/doctor_appointments') do
                      t(:li, {}, "my appointments")
                    end
                  )
                )
              end,
              if state.current_user.has_role? [:appointment_scheduler]
                t(:div, {className: 'roles_block'},
                  t(:p, {className: 'role_category'}, "actions for appointment scheduler"),
                  t(:ul, {},
                    link_to('', '/users/dashboard/appointments_proposals') do
                      t(:li, {}, "appointments requests")  
                    end,
                    
                    t(:li, { onClick: ->{ init_appointment_schedulers_appointments_index } }, "browse schedule"),
                    t(:li, { onClick: ->{ init_user_appointment_schedulers_new } }, 'register patient'),
                    t(:li, { onClick: ->{ init_user_appointment_schedulers_index } }, 'manage patients'),
                    t(:li, { onClick: ->{ init_appointment_schedulers_chat_messages_index } }, 'browse chats')
                  )
                ) 
              end
            ),
            t(:div, {className: "col-lg-10 content"},
              children
            )
          )  
        end

      end
    end
  end
end
