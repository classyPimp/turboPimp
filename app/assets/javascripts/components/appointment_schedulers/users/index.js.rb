module Components
  module AppointmentSchedulers
    module Users
      class Index < RW
        
        expose

        include Plugins::DependsOnCurrentUser
        set_roles_to_fetch :appointment_scheduler

        include Plugins::Paginatable

        def get_initial_state
          {
            users: ModelCollection.new
          }
        end

        def component_did_mount
          User.index({extra_params: {per_page: 25}, namespace: 'appointment_scheduler'}).then do |users|
            extract_pagination(users)
            set_state users: users
          end
        end

        def render
          t(:div, {},
            modal,
            *splat_each(state.users) do |user|
              t(:div, {},
                if user.avatar 
                  t(:image, {src: user.avatar.url, style: {width: "60px", height: "60px"}.to_n })
                end,
                t(:p, {},"email: #{user.email}"),
                if user.profile
                  t(:div, {}, 
                    t(:p, {}, link_to("name: #{user.profile.name}", "/users/show/#{user.id}" ) ),
                    t(:p, {}, "phone_number: #{user.profile.phone_number}")
                  )
                end,
                unless user.attributes[:registered]
                  t(:p, {}, "*unregistered")
                end,
                t(:div, {},  
                  t(:br, {}),
                  t(:button, {onClick: ->{edit_selected_as_appointment_scheduler(user)} }, "edit user"),
                  t(:button, {onClick: ->{delete_selected_as_appointment_scheduler(user)}}, "delete user")
                ),
                t(:hr, {style: {color: "grey", height: "1px", backgroundColor: "black"}.to_n }),      
              )
            end,
            unless state.users.data.empty?
              will_paginate
            end
          )
        end

        def edit_selected_as_appointment_scheduler(user)
          modal_open(
            'edit user',
            t(Components::AppointmentSchedulers::Users::Edit, {user: user})
          )
        end

        def delete_selected_as_appointment_scheduler(_user)
          _user.destroy(namespace: 'appointment_scheduler').then do |user|
            state.users.remove(_user)
            set_state users: state.users
          end
        end

      end
    end
  end
end