module Components
  module Doctors
    class Index < RW
      #expose


      def get_initial_state
        {
          users: ModelCollection.new
        }
      end

      def component_did_mount
        User.index_doctors_for_group_list(namespace: 'doctor').then do |users|
          set_state users: users
        end
      end

      def render
        t(:div, {className: 'container doctor_index'},
          *if props.children
            [
              t(:div, {className: 'col-lg-8 doctor_show'},
                children
              ),
              t(:div, {className: 'col-lg-4 doctor_panel'},  
                *self.doctor_partial.call
              )
            ]
          else
            t(:div, {className: 'center-block'},
              t(:p, {}, 'click on doctor avatar to get information on him'),  
              *self.doctor_partial.call
            )
          end
        )
      end

      def doctor_partial
        ->{
          splat_each(state.users) do |user|
            t(:div, {className: 'thumbnail'},
              if user.avatar 
                t(:image, {src: user.avatar.url, className: 'avatar'})
              end,
              t(:div, {className: 'profile_info'}, 
                t(:h3, {className: 'profile_name'}, user.profile.name ),
                link_to("", "/personnel/#{user.id}") do |variable|
                  t(:button, {className: 'btn btn-default'}, 'more info')
                end     
              )
            )
          end          
        }
      end

    end
  end
end