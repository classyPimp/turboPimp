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
        t(:div, {className: 'pages_show'},
          spinner,
          if state.page
            t(:div, {className: 'pages_show_content'},
              t(:div, {dangerouslySetInnerHTML: {__html: state.page.body}.to_n})
            )
          else
            t(:p, {}, "loading") 
          end
        )
      end
    end

  end
end