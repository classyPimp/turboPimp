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
          component_ready
        end.fail do |resp|
          raise resp
        end
        Element.find('.pages_show').on('click.reactive_link', 'a') do |e|
          el = e.target
          if el.has_class?('react_link')
            e.prevent
            href = e.target.attr('href')
            Components::App::Router.history.pushState(nil, href)
          end
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

      def component_will_unmount
        Element.find('.pages_show').off('click.reactive_link')
      end

    end
  end
end