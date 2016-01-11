module Components
  module Menues
    class IndexEdit < RW
      expose

      def get_initial_state
        {
          menu: false
        }
      end

      def component_did_mount
        menu = MenuItem.index.then do |_menu|
          set_state menu: _menu
        end
      end

      def render
        t(:div, {},
          if state.menu
            t(:div, {},
              t(:p, {}, "add top level menu branch"),
              t(Components::Menues::New, {parent_menu_item: state.menu, on_menu_item_added: ->(_menu_i){handle_item_change(_menu_i)}}),
              *splat_each(state.menu.menu_items) do |menu_item|
                next if menu_item.attributes[:_destroy]
                t(:div, {},
                  t(:p, {}, "link_text#{menu_item.link_text}, href: #{menu_item.href}"),
                  t(:button, {onClick: ->{destruct(menu_item)}}, "delete"),
                  if menu_item.arbitrary[:marked_for_edit]
                    t(:div, {},
                      t(Components::Menues::Edit, {menu_item_to_edit: menu_item, on_menu_item_edited: ->(m_i){handle_item_change(m_i)}}),
                      t(:button, {onClick: ->(){cancel_item_editing_for(menu_item)}}, "cancel")                     
                    )
                  else
                    t(:button, {onClick: ->(){init_edit_for(menu_item)}}, "edit this entry")
                  end,
                  *splat_each(menu_item.menu_items) do |sub_item|
                    next if sub_item.attributes[:_destroy]
                    t(:div, {style: {"paddingLeft" => "3em"}},
                      t(:p, {}, "href#{sub_item.href},link_text:#{sub_item.link_text}"),
                      t(:button, {onClick: ->{destruct(sub_item)}}, "delete"),
                      if sub_item.arbitrary[:marked_for_edit]
                        t(:div, {},
                          t(Components::Menues::Edit, {menu_item_to_edit: sub_item, on_menu_item_edited: ->(m_i){handle_item_change(m_i)}}),
                          t(:button, {onClick: ->(){cancel_item_editing_for(sub_item)}}, "cancel")                     
                        )
                      else
                        t(:button, {onClick: ->(){init_edit_for(sub_item)}}, "edit this entry")
                      end
                    )
                  end,
                  if menu_item.arbitrary[:marked_for_addition]
                    t(:div, {},
                      t(Components::Menues::New, {parent_menu_item: menu_item, on_menu_item_added: ->(m_i){handle_item_change(m_i)}}),
                      t(:button, {onClick: ->(){cancel_item_addition_for(menu_item)}}, "cancel")                     
                    )
                  else
                    t(:button, {onClick: ->(){init_addition_for(menu_item)}}, "add menu_item on this branch")
                  end
                )
              end,
              t(:button, {onClick: ->{update_menu}}, "save changes"),
              t(:button, {onClick: ->{refetch}}, "clear unsaved")
            )
          end
        )
      end

      def init_edit_for(menu_item)
        menu_item.arbitrary[:marked_for_edit] = true
        set_state menu: state.menu
      end

      def init_addition_for(menu_item)
        menu_item.arbitrary[:marked_for_addition] = true
        set_state menu: state.menu
      end

      def cancel_item_editing_for(menu_item)
        menu_item.arbitrary[:marked_for_edit] = false
        set_state menu: state.menu
      end

      def cancel_item_addition_for(menu_item)
        menu_item.arbitrary[:marked_for_addition] = false
        set_state menu: state.menu
      end

      def handle_item_change(menu_item)
        menu_item.arbitrary[:marked_for_addition] = false
        menu_item.arbitrary[:marked_for_edit] = false
        set_state menu: state.menu
      end

      def destruct(item)
        item.attributes[:_destroy] = 1
        set_state menu: state.menu
      end

      def update_menu
        state.menu.update.then do |menu|
          alert "updated, look at menu now!"
          set_state menu: menu
          Components::App::Main.instance.ref(:menu).rb.set_state menu: menu
        end.fail do |resp|
          raise resp
        end
      end

    end
  end
end

