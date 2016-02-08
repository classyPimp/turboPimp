module Components
  module Doctors
    class Show < RW
      expose

      def get_initial_state
        {
          user: false
        }
      end

      def component_did_mount
        User.show(namespace: 'doctor', wilds: {id: props.params.id}, component: self).then do |user|
          set_state user: user
        end
      end

      def component_did_update(prev_props, prev_state)
        if state.user && (prev_props.params.id != props.params.id)
          component_did_mount
        end
      end

      def render
        t(:div, {},
          spinner,
          if state.user
            t(:div, {}, 
              t(:div, {},
                t(:div, {},
                  t(:image, {src: "#{state.user.try(:avatar).try(:url)}", style: {width: "100px", height: "100px"}.to_n }, )
                ),
                t(:p, {}, "name: #{state.user.try(:name)}"),
                t(:p, {}, "bio: #{state.user.try(:profile).try(:bio)}")
              )
            )
          end
        )
      end

    end
  end
end