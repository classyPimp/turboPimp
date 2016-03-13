module Components
  module Menues
    class IndexEdit < RW
      expose

      def get_initial_state
        {
          menu: false,
          menu_item_to_edit: false,
          menu_item_to_add_to: false,
          collapsed: false
        }
      end

      def component_did_mount
        menu = MenuItem.index(component: self).then do |_menu|
          set_state menu: _menu
        end
      end

      def render
        if state.menu
          t(:div, {className: 'row menu_edit_index'},
            t(:h3, {}, 'edit menu'), 
            t(:nav, {className: "navbar navbar-default menu_index"},
              t(:div, {className: "container-fluid"},
                t(:div, {className: "navbar-header"},
                  t(:button, {type: "button", className: "navbar-toggle collapsed",
                              "aria-expanded" => "false", onClick: ->(){toggle_collapse()}},
                    t(:span, {className: "sr-only"}, "toggle navigation"),
                    t(:span, {className: "icon-bar"}),
                    t(:span, {className: "icon-bar"}),
                    t(:span, {className: "icon-bar"})
                  ),
                  link_to("HOME", "/", {}, {className: 'navbar-brand'})
                ),

                t(:div, {className: "collapse navbar-collapse #{state.collapsed ? "in" : ""}"},
                  t(Components::Users::LoginInfo, {}),
                  t(:ul, {className: "nav navbar-nav after_login_info"},
                    *splat_each(state.menu.menu_items) do |menu_item|
                      if menu_item.menu_items.empty?
                        next if menu_item.attributes[:_destroy]
                        t(:li, {}, 
                          link_to(menu_item.link_text, menu_item.href),
                          t(:button, {className: 'btn btn-xs', onClick: ->(){init_edit_for(menu_item)}}, 
                            'edit'
                          ),
                          t(:button, {className: 'btn btn-xs', onClick: ->{destruct(menu_item)}}, 
                            'delete'
                          ),
                          t(:button, {className: 'btn btn-xs', onClick: ->{init_addition_for(menu_item)}}, 
                            'add items here'
                          )
                        )
                      else
                        t(Shared::Dropdown, {on_toggle: ->(d_d){clear_opened(d_d)}, caller: self, 
                                             ref: "d_d_#{menu_item.id}", text_val: "#{menu_item.link_text}"},
                          t(:ul, {className: "dropdown-menu"},
                            *splat_each(menu_item.menu_items) do |sub_item|
                              next if sub_item.attributes[:_destroy]
                              t(:li, {}, 
                                link_to(sub_item.link_text, sub_item.href),
                                t(:button, {className: 'btn btn-xs', onClick: ->(){init_edit_for(sub_item)}}, 
                                  'edit'
                                ),
                                t(:button, {className: 'btn btn-xs', onClick: ->{destruct(sub_item)}}, 
                                  'delete'
                                )
                              )
                            end,
                            t(:li, {}, 
                              t(:button, {className: 'btn btn-xs', onClick: ->{init_addition_for(menu_item)}}, 
                                'add items here'
                              )
                            )
                          )
                        )
                      end
                    end,
                    t(:li, {}, 
                      t(:button, {className: 'btn btn-xs', onClick: ->{init_addition_for(state.menu)}}, 
                        'add top_level'
                      )
                    )
                  )                
                )
              )
            ),
            t(:div, {className: 'edit_box'}, 
              if state.menu_item_to_edit
                t(:div, {key: "#{state.menu_item_to_edit}"},
                  t(Components::Menues::Edit, {menu_item_to_edit: state.menu_item_to_edit, on_menu_item_edited: ->(m_i){handle_item_change(m_i)}}),
                  t(:button, {onClick: ->(){cancel_edit}}, "cancel")                     
                )
              end,
              if state.menu_item_to_add_to
                t(:div, {key: "#{state.menu_item_to_add_to}"},
                  t(Components::Menues::New, {parent_menu_item: state.menu_item_to_add_to, on_menu_item_added: ->(m_i){handle_item_change(m_i)}}),
                  t(:button, {onClick: ->(){cancel_edit}}, "cancel")                     
                )
              end,
              t(:div, {className: 'controll_buttons'}, 
                t(:button, {onClick: ->{update_menu}}, "save all changes"),
                t(:button, {onClick: ->{refetch}}, "clear unsaved")
              )
            )
          )
        else
          spinner
        end
        # t(:div, {},
        #   if state.menu
        #     t(:div, {},
        #       t(:p, {}, "add top level menu branch"),
        #       t(Components::Menues::New, {parent_menu_item: state.menu, on_menu_item_added: ->(_menu_i){handle_item_change(_menu_i)}}),
        #       *splat_each(state.menu.menu_items) do |menu_item|
        #         next if menu_item.attributes[:_destroy]
        #         t(:div, {},
        #           t(:p, {}, "link_text#{menu_item.link_text}, href: #{menu_item.href}"),
        #           t(:button, {onClick: ->{destruct(menu_item)}}, "delete"),
        #           if menu_item.arbitrary[:marked_for_edit]
        #             t(:div, {},
        #               t(Components::Menues::Edit, {menu_item_to_edit: menu_item, on_menu_item_edited: ->(m_i){handle_item_change(m_i)}}),
        #               t(:button, {onClick: ->(){cancel_item_editing_for(menu_item)}}, "cancel")                     
        #             )
        #           else
        #             t(:button, {onClick: ->(){init_edit_for(menu_item)}}, "edit this entry")
        #           end,
        #           *splat_each(menu_item.menu_items) do |sub_item|
        #             next if sub_item.attributes[:_destroy]
        #             t(:div, {style: {"paddingLeft" => "3em"}},
        #               t(:p, {}, "href#{sub_item.href},link_text:#{sub_item.link_text}"),
        #               t(:button, {onClick: ->{destruct(sub_item)}}, "delete"),
        #               if sub_item.arbitrary[:marked_for_edit]
        #                 t(:div, {},
        #                   t(Components::Menues::Edit, {menu_item_to_edit: sub_item, on_menu_item_edited: ->(m_i){handle_item_change(m_i)}}),
        #                   t(:button, {onClick: ->(){cancel_item_editing_for(sub_item)}}, "cancel")                     
        #                 )
        #               else
        #                 t(:button, {onClick: ->(){init_edit_for(sub_item)}}, "edit this entry")
        #               end
        #             )
        #           end,
        #           if menu_item.arbitrary[:marked_for_addition]
        #             t(:div, {},
        #               t(Components::Menues::New, {parent_menu_item: menu_item, on_menu_item_added: ->(m_i){handle_item_change(m_i)}}),
        #               t(:button, {onClick: ->(){cancel_item_addition_for(menu_item)}}, "cancel")                     
        #             )
        #           else
        #             t(:button, {onClick: ->(){init_addition_for(menu_item)}}, "add menu_item on this branch")
        #           end
        #         )
        #       end,
        #       t(:button, {onClick: ->{update_menu}}, "save changes"),
        #       t(:button, {onClick: ->{refetch}}, "clear unsaved")
        #     )
        #   end
        # )
      end

      def cancel_edit
        set_state menu_item_to_edit: false, menu_item_to_add_to: false
      end

      def init_edit_for(menu_item)
        set_state menu_item_to_edit: menu_item, menu_item_to_add_to: false
      end

      def init_addition_for(menu_item)
        set_state menu_item_to_add_to: menu_item, menu_item_to_edit: false
      end

      def cancel_item_editing_for(menu_item)
        set_state menu_item_to_edit: false
      end

      def cancel_item_addition_for(menu_item)
        set_state menu_item_to_add_to: false
      end

      def handle_item_change(menu_item)
        set_state menu: state.menu, menu_item_to_add_to: false, menu_item_to_edit: false
      end

      def refetch
        component_did_mount
      end

      def destruct(item)
        item.attributes[:_destroy] = 1
        set_state menu: state.menu
      end

      def toggle_collapse 
        set_state collapsed: !state.collapsed
      end

      def clear_opened(d_d)
        refs.each do |k,v|
          if k.include? "d_d"
            v.rb.set_state open: false unless (v.rb == d_d)
          end
        end
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

