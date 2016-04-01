module Components
  module Admin  
    module OfferedServices
      class Index < RW
        expose

        include Plugins::DependsOnCurrentUser
        set_roles_to_fetch :admin

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
                t(:button, {className: 'btn btn-xs'}, 'details'),
                link_to('', "/admin/offered_services/edit/#{offered_service.id}") do
                  t(:buttin, {className: 'btn btn-xs'}, 'edit')                  
                end,
                t(:button, {className: 'btn btn-xs btn-danger', onClick: ->{destroy(offered_service)}}, 'destroy')
              )
            end
          )
        end

        def destroy(offered_service)
          offered_service.destroy(namespace: 'admin').then do |_offered_service|
            state.offered_services.remove(offered_service)
            set_state offered_services: state.offered_services
          end 
        end

      end
    end
  end
end