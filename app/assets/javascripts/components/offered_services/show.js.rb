module Components
  module OfferedServices
    class Show < RW
      expose

      def get_initial_state
        {
          offered_service: false
        }
      end

      def component_did_mount
        offered_service_to_query = (x = props.offered_service_id) ? x : props.params.id
        OfferedService.show(wilds: {id: offered_service_to_query}, component: self).then do |offered_service|
          set_state offered_service: offered_service
          component_ready
        end.fail do |resp|
          raise resp
        end
        Element.find('.offered_services_show').on('click.reactive_link', 'a') do |e|
          el = e.target
          if el.has_class?('react_link')
            e.prevent
            href = e.target.attr('href')
            Components::App::Router.history.pushState(nil, href)
          end
        end
      end

      def render
        t(:div, {className: 'offered_services_show container'},
          spinner,
          if state.offered_service
            t(:div, {className: 'show_content'},
              t(:img, {className: "avatar"}, offered_service.avatar.try(:url)),
              t(:h1, {}, offered_service.title),
              t(:div, {dangerouslySetInnerHTML: {__html: state.offered_service.body}.to_n}),
              if !state.offered_service.price_items.empty?
                t(:div, {className: 'prices'},
                  t(:p, {}, 'prices'),
                  *splat_each(state.offered_service.price_items) do |price_item|
                    t(:p, {}, "#{price_item.name} : #{price_item.price}")
                  end
                )
              end
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