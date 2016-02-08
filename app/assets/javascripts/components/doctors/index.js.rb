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
        t(:div, {className: 'row'},
          t(:div, {className: 'col-lg-8'},
            children
          ),
          t(:div, {className: 'col-lg-4'},  
            *splat_each(state.users) do |user|
              t(:div, {},
                if user.avatar 
                  t(:image, {src: user.avatar.url, style: {width: "60px", height: "60px"}.to_n })
                end,
                t(:p, {}, user.profile.name ),
                t(:button, {}, link_to("more info", "/personnel/#{user.id}") )    
              )
            end
          )
        )
      end

    end
  end
end