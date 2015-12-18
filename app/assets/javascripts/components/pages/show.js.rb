module Components
  module Pages
    class Show < RW
      expose

      def get_initial_state
        {
          page: false 
        }
      end

      def component_did_mount
        page_to_query = (x = props.page_id) ? x : props.params.id
        Page.show(wilds: {id: page_to_query}, component: self).then do |page|
          set_state page: page
        end.fail do |resp|
          raise resp
        end
      end

      def render
        t(:div, {},
          spinner,
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