
module Components
  module Menues
    class Index < RW
    
      expose
      include Helpers::UpdateOnSetStateOnly

      def initial_state
        {
          menu: false,
          collapsed: false
        }
      end

      def component_did_mount
        menu = MenuItem.index.then do |_menu|
          self.set_state menu: _menu
        end
      end

      def component_will_update
        p "#{self} updated"
      end
      
      def render
        if state.menu
          t(:nav, {className: "navbar navbar-default"},
            t(:div, {className: "container-fluid"},
              t(:div, {className: "navbar-header"},
                t(:button, {type: "button", className: "navbar-toggle collapsed",
                            "aria-expanded" => "false", onClick: ->(){toggle_collapse(:collapsed_navbar)}},
                  t(:span, {className: "sr-only"}, "toggle navigation"),
                  t(:span, {className: "icon-bar"}),
                  t(:span, {className: "icon-bar"}),
                  t(:span, {className: "icon-bar"})
                ),
                t(:a, {className: "navbar-brand"}, "Home")
              ),
              t(:form, {className: "navbar-form navbar-left"},
                t(:ul, {},
                  t(Users::LoginInfo, {})
                )
              ),
              t(:ul, {className: "nav navbar-nav navbar-right"},
                *splat_each(state.menu.menu_items) do |menu_item|
                  if menu_item.menu_items.empty?
                    t(:li, {}, 
                      link_to(menu_item.link_text, menu_item.href)
                    )
                  else
                    t(Shared::Dropdown, {on_toggle: ->(d_d){clear_opened(d_d)}, caller: self, 
                                         ref: "d_d_#{menu_item.id}", text_val: "#{menu_item.link_text}"},
                      t(:ul, {className: "dropdown-menu"},
                        *splat_each(menu_item.menu_items) do |sub_item|
                          t(:li, {}, 
                            link_to(sub_item.link_text, sub_item.href)
                          )
                        end
                      )
                    )
                  end
                end
              )
            )
          )
        else
          t(:p, {}, "loading")
        end
      end

      def toggle_collapse 
        set_state collapsed: !state.collapsed
      end

      def clear_opened(d_d)
        refs.each do |k,v|
          if k.include? "d_d"
            v.__opalInstance.set_state open: false unless (v.__opalInstance == d_d)
          end
        end
      end

    end
  end
end