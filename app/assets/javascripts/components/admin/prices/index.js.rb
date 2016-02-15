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
          t(:div, {},
            t(:div, {className: 'new_category_form'},
              t(:p, {}, 'add new category'),
              t(Components::Admin::PriceCategories::New, {on_price_category_created: event(->(price_category){on_price_category_created(price_category)})})
            ),
            t(:div, {className: 'price_list'},
              *splat_each(state.price_categories) do |price_category|
                t(:div, {className: 'price_category_wrapper'},
                  t(:h1, {}, price_category.name),
                  if state.price_items_to_add_to[price_category.id]
                    t(Components::Admin::PriceItems::New, {on_price_item_created: event(->(price_item){on_price_item_created(price_item)}), on_price_item_new_cancel: event(->(price_category){on_price_item_new_cancel(price_category)}), price_category: price_category})
                  else
                    t(:div, {},
                      t(:button, { onClick: ->{init_price_item_new(price_category)} }, 'add new price item'),
                      t(:button, { onClick: ->{destroy_price_category(price_category)} }, 'destroy category')
                    )
                  end,
                  *splat_each(price_category.price_items) do |price_item|
                    t(:div, {className: 'price_item_list_wrapper'},
                      t(:p, {}, "#{price_item.name} :::::::: #{price_item.price}"),
                      t(:button, {onClick: ->{delete_price_item(price_item)}}, "delete this")
                    )
                  end
                )
              end
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