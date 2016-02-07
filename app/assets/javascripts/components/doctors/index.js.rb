module Components
  module Doctors
    class Index < RW
      expose


      def get_initial_state
        {
          users: ModelCollection.new
        }
      end

      def component_did_mount
        User.doctor_index(namespace: 'doctor').then do |users|
          set_state users: users
        end
      end

      def render
        t(:div, {},
          *splat_each(state.users) do |user|
            t(:div, {},
              if user.avatar 
                t(:image, {src: user.avatar.url, style: {width: "60px", height: "60px"}.to_n })
              end,
              t(:p, {}, (link_to("name: #{user.profile.name}", "/users/show/#{user.id}" )) )    
            )
          end
        )
      end

    end
  end
end