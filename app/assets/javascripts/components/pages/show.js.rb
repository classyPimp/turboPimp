module Components
  module Pages
    class Show < RW
      expose

      def initial_state
        {
          page: false 
        }
      end

      def component_did_mount
        Page.show({id: props.params.id}).then do |page|
          set_state page: page
        end.fail do |resp|
          raise resp
        end
      end

      def render
        t(:div, {},
          if state.page
            t(:div, {},
              t(:div, {dangerouslySetInnerHTML: {__html: state.page.body}})
            )
          else
            t(:p, {}, "loading") 
          end
        )
      end
    end

  end
end