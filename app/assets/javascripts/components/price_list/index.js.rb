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
        t(:div, {}, 
          t(:p, {}, ),
          t(:div, {className: 'table-responsive'}, 
            t(:table, {className: 'table'}, 
              t(:thead, {}, 
                t(:tr, {}, 
                  t(:th, {}, 'name'),
                  t(:th, {}, 'price')
                )
              ),
              t(:tbody, {}, 

                splat_each(state.price_categories) do |price_category|                  
                  [ 
                  t(:tr, {},
                    t(:td, {colSpan: 2}, 
                      "#{price_category.name}"
                    )
                  ),
                  *splat_each(price_category.price_items) do |price_item|
                    t(:tr, {}, 
                      t(:td, {}, "#{price_item.name}"),
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