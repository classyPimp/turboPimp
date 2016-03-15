module Components 
  module Admin
    module Prices
      class Index < RW
        expose

        include Plugins::DependsOnCurrentUser
        set_roles_to_fetch :admin

        def get_initial_state
          {
            price_categories: ModelCollection.new,
            price_items_to_add_to: {}
          }
        end

        def component_did_mount
          PriceCategory.index(namespace: 'admin').then do |price_categories|
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
                    if state.price_items_to_add_to[price_category.id]
                      t(:tr, {}, 
                        t(:td, {},
                          t(Components::Admin::PriceItems::New, {on_price_item_created: event(->(price_item){on_price_item_created(price_item)}), on_price_item_new_cancel: event(->(price_category){on_price_item_new_cancel(price_category)}), price_category: price_category})
                        )
                      )
                    else
                      t(:tr, {colSpan: 2},
                        t(:td, {},
                          t(:button, {className: 'btn btn-xs', onClick: ->{init_price_item_new(price_category)} }, 'add new price item'),
                          t(:button, {className: 'btn btn-xs', onClick: ->{destroy_price_category(price_category)} }, 'destroy category')
                        )
                      )
                    end,    
                    *splat_each(price_category.price_items) do |price_item|
                      t(:tr, {className: 'price_item'}, 
                        t(:td, {}, 
                          t(:button, {className: 'btn btn-xs' ,onClick: ->{delete_price_item(price_item)}}, "delete"),
                          "#{price_item.name}"
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

        def init_price_item_new(price_category)
          state.price_items_to_add_to[price_category.id] = true
          set_state price_items_to_add_to: state.price_items_to_add_to
        end

        def on_price_category_created(price_category)
          state.price_categories << price_category
          set_state price_categories: state.price_categories
        end

        def on_price_item_created(price_item)

          state.price_categories.each do |price_category|
            if price_category.id == price_item.price_category_id
              price_category.price_items << price_item
            end
          end

          state.price_items_to_add_to.delete(price_item.price_category_id)

          set_state price_categories: state.price_categories
          
        end

        def on_price_item_new_cancel(price_category)
          state.price_items_to_add_to.delete(price_category.id)
          set_state price_items_to_add_to: state.price_items_to_add_to
        end

        def delete_price_item(price_item)
          price_item.destroy(namespace: 'admin').then do |_price_item|
            begin
            state.price_categories.each do |price_category|
              if price_category.id == price_item.price_category_id
                price_category.price_items.delete_if do |price_item_in_array|
                  price_item_in_array.id == _price_item.id
                end
              end
              set_state price_categories: state.price_categories
            end
            rescue Exception => e
              p e
            end
          end
        end

        def destroy_price_category(price_category)
          price_category.destroy(namespace: 'admin').then do |_price_category|
            state.price_categories.remove(price_category)
            set_state price_categories: state.price_categories
          end
        end

      end
    end
  end
end