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
            price_items_to_add_to: {},
            current_edited_price_item: nil,
            current_edited_price_category: nil
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

                  t(:tr, {}, 
                    t(:td, {colSpan: 2}, 
                      t(Components::Admin::PriceCategories::New, {on_price_category_created: event(->(category){on_price_category_created(category)}), show_name: 'add new category'}, )
                    )
                  ), 

                  splat_each(state.price_categories) do |price_category|              
                    [ 
                    t(:tr, {className: 'category_name'},
                      t(:td, {colSpan: 2},
                        *if price_category.id == state.current_edited_price_category 
                          t(Components::Admin::PriceCategories::Edit, {form_model: price_category, on_price_category_updated: event(->(_category){on_price_category_updated(_category)}), on_price_category_edit_cancel: event(->{on_price_category_edit_cancel})} )
                        else
                          [
                          t(:button, {className: 'btn btn-xs', onClick: ->{init_price_category_edit(price_category)}}, 'edit category name'),
                          "#{price_category.name}"
                          ]
                        end
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

                        *if state.current_edited_price_item == price_item.id
                          t(:td, {colSpan: 2}, 
                            t(Components::Admin::PriceItems::Edit, {form_model: price_item, on_price_item_updated: event(->(_price_item){on_price_item_updated(_price_item)}), on_price_item_edit_cancel: event(->{on_price_item_edit_cancel})})
                          )
                          
                        else
                          [
                            t(:td, {}, 
                              t(:button, {className: 'btn btn-xs', onClick: ->{delete_price_item(price_item)}}, "delete"),
                              t(:button, {className: 'btn btn-xs', onClick: ->{init_price_item_edit(price_item)}}, 'edit'),
                              "#{price_item.name}"
                            ),
                            t(:td, {}, "#{price_item.price}")
                          ]
                        end
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

        def init_price_item_edit(price_item)
          set_state current_edited_price_item: price_item.id 
        end

        def on_price_item_updated(price_item)
          set_state price_categories: state.price_categories, current_edited_price_item: nil
        end

        def on_price_item_edit_cancel
          set_state current_edited_price_item: nil
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

        def on_price_category_edit_cancel
          set_state current_edited_price_category: nil
        end

        def init_price_category_edit(category)
          set_state current_edited_price_category: category.id
        end

        def on_price_category_updated(category)

          set_state price_categories: state.price_categories, current_edited_price_category: nil

        end

      end
    end
  end
end