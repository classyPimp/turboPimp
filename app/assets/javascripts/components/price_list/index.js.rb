module Components
  module PriceList
    class Index < RW
      expose

      def get_initial_state
        {
          price_categories: ModelCollection.new,
        }
      end

      def component_did_mount
        PriceCategory.index.then do |price_categories|
          set_state price_categories: price_categories
        end
      end

      def render
        t(:div, {className: 'pricelist container'}, 
          t(:p, {className: 'disclaimer'}, 'the prices are not final and depend on patients condition'),
          t(:div, {className: 'table-responsive'}, 
            t(:table, {className: 'table table-striped table-condensed'}, 
              t(:thead, {}, 
                t(:tr, {}, 
                  t(:th, {}, 'service'),
                  t(:th, {}, 'price')
                )
              ),
              t(:tbody, {}, 

                splat_each(state.price_categories) do |price_category|                  
                  [ 
                  t(:tr, {className: 'category_name'},
                    t(:td, {colSpan: 2}, 
                      "#{price_category.name}"
                    )
                  ),
                  *splat_each(price_category.price_items) do |price_item|
                    t(:tr, {className: 'price_item'}, 
                      t(:td, {}, 
                        "#{price_item.name}",
                        if price_item.offered_service
                          link_to('+more detatils', "/offered_services/show/#{price_item.offered_service.slug}")
                        end
                      ),
                      t(:td, {}, "#{price_item.price}")
                    )
                  end
                  ]
                end                  
              ) 
            )
          )
        )
      end

    end
  end
end