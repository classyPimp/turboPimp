module Components
  module Doctors
    class Show < RW
      expose

      def init
        yields_phantom_ready
      end

      def get_initial_state
        {
          user: false
        }
      end

      def component_did_mount
        User.show(namespace: 'doctor', wilds: {id: props.params.id}, component: self).then do |user|
          set_state user: user
          component_phantom_ready
        end
      end

      def component_did_update(prev_props, prev_state)
        if state.user && (prev_props.params.id != props.params.id)
          component_did_mount
        end
      end

      def render
        t(:div, {className: 'doctor_show'},
          spinner,
          if state.user
            t(:div, {},
              t(:span, {}, 
                t(:image, {src: "#{state.user.try(:avatar).try(:url)}", style: {width: "100px", height: "100px"}.to_n })
              ),
              t(:h4, {className: 'name'}, "#{state.user.profile.try(:name)}"),
              t(:div, {className: 'bio', dangerouslySetInnerHTML: {__html: state.user.try(:profile).try(:bio)}.to_n})
            )
          end
        )
      end

    end
  end
end