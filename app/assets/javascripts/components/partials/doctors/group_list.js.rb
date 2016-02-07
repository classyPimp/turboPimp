module Components
  module Partials
    module Doctors
      class ListGroup < RW

        expose

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
          t(:div, {className: 'list-group'},
            t(:p, {className: 'list-group-item'}, 
              'our doctors'
            ), 
            *splat_each(state.users) do |user|
              t(:div, {className: 'list-group-item'}, 
                if user.avatar
                  t(:image, {src: user.avatar.url, className: 'user_avatar_in_group_list', style: {width: "60px", height: "60px"}.to_n},

                  )
                end,
                t(:p, {}, user.profile.name)
              )
            end
          )
        end

      end
    end
  end
end