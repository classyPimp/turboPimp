module Components
  module Partials
    module Doctors
      class ListGroup < RW

        expose

        def init
          yields_phantom_ready
        end

        def get_initial_state
          {
            users: ModelCollection.new
          }
        end

        def component_did_mount
          User.index_doctors_for_group_list(namespace: 'doctor').then do |users|
            set_state users: users
            component_phantom_ready
          end
        end

        def render
          t(:div, {className: 'list-group'},
            t(:div, {className: 'list-group-item list_group_title'},
              t(:h3, {}, 
                'our doctors',
              ), 
              t(:p, {className: 'list_group_more_info_button'}, link_to('...browse all doctors', '/personnel'))
            ),
            *splat_each(state.users) do |user|
              t(:div, {className: 'list-group-item'}, 
                t(:div, {className: 'row'},
                  t(:div, {className: 'col-lg-4'},
                    if user.avatar
                      link_to('', "/personnel/#{user.id}") do
                        t(:image, {src: user.avatar.url, className: 'user_avatar_in_group_list', style: {width: "60px", height: "60px"}.to_n})
                      end
                    end
                  ),
                  t(:div, {className: 'col-lg-4'},
                    t(:p, {className: 'user_name_in_group_list'}, user.profile.name),
                    t(:p, {className: 'list_group_more_info_button'}, link_to('more details', "/personnel/#{user.id}"))
                  ),
                  t(:div, {className: 'col-lg-4'})
                )
              )
            end
          )
        end

      end
    end
  end
end