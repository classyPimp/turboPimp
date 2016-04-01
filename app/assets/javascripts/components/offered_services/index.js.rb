module Components
  module OfferedServices
    class Index < RW
      expose

      def get_initial_state
        {
          offered_services: ModelCollection.new
        }
      end

      def component_did_mount
        OfferedService.index.then do |offered_services|
          begin
          set_state offered_services: offered_services
          rescue Exception => e
            p e
          end
        end
      end

      def render
        t(:div, {className: 'offered_services_index'},
          *splat_each(state.offered_services) do |offered_service|
            t(:div, {className: 'box'},
              t(:img, {className: 'avatar', src: "#{offered_service.avatar.try(:url)}"}),
              t(:p, {}, offered_service.title),
              t(:div, {},
                *splat_each(offered_service.price_items) do |price_item|
                  t(:p, {}, "#{price_item.name} : #{price_item.price}")
                end
              ),
              link_to('', "/offered_services/show/#{offered_service.slug}") do
                t(:button, {className: 'btn btn-xs'}, 'details')                
              end
            )
          end
        )
      end

    end
  end
end
