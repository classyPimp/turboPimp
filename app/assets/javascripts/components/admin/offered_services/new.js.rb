module Components
  module Admin  
    module OfferedServices
      class New < RW

        expose

        include Plugins::Formable
        include Plugins::DependsOnCurrentUser
        set_roles_to_fetch :admin

        def get_initial_state
          {
            form_model: OfferedService.new
          }        
        end

        def render
          t(:div, {className: 'offered_services_new'},
            if state.current_user.has_role? :admin
              t(:div, {}, 
                modal,
                input(Forms::Input, state.form_model, :title, {type: "text", show_name: 'title'}),
                input(Forms::Input, state.form_model, :m_title, {type: "text", show_name: 'meta title'}),
                input(Forms::Input, state.form_model, :m_description, {type: "text", show_name: 'meta description'}),
                input(Forms::Input, state.form_model, :m_keywords, {type: "text", show_name: 'meta keywords'}),
                input(Forms::WysiTextarea, state.form_model, :body),
                if !state.form_model.price_items.empty? 
                  t(:div, {}, 
                    *splat_each(state.form_model.price_items) do |price_item|
                      t(:div, {},
                        *if !price_item.attributes['_destroy']
                          [
                            t(:p, {}, price_item.name),
                            t(:button, {onClick: ->{remove_associated_price_item(price_item)}}, 'remove')
                          ]
                        end
                      )
                    end
                  )
                end,
                t(:button, { onClick: ->{init_adding_associated_price_item}, className: 'btn btn-xs' }, '+add associated price item')
                t(:button, {className: 'btn btn-primary', onClick: ->(){handle_inputs}}, "create blog")
              )
            end
          )
        end

        def handle_inputs
          collect_inputs
          unless state.form_model.has_errors?
            state.form_model.create(name_space: 'admin').then do |model|
              if model.has_errors?
                set_state form_model: model
              else
                msg = Shared::Flash::Message.new(t(:div, {}, 
                                                  t(:p, {}, "service has been saved"),
                                                  link_to("go to created resource", "/offered_services/#{state.form_model.id}"),
                                                  t(:a, {onClick: ->{start_new}}, "or create one more")
                                                ))
                Components::App::Main.instance.ref(:flash).rb.add_message(msg)
                state.form_model = model
                props.history.pushState(nil, '/users/dashboard')
              end
            end
          else
            set_state form_model: state.form_model
          end
        end

        def start_new
          set_state form_model: Blog.new
        end

        def remove_associated_price_item(price_item)
          state.form_model.price_items.each do |p_i|
            if p_i == price_item
              p_i.attributes['_destroy'] = 1
            end
          end
          set_state form_model: state.form_model
        end

        def init_adding_associated_price_item
          modal_open(
            'choose price item to associate',
            t(Components::Admin::PriceItems::Edit, {as_model_provider: true, add_associated_price_item: event(->(price_item){add_associated_price_item(price_item)})})
          )
        end

        def add_associated_price_item(price_item)
          _price_item = PriceItem.new(id: price_item.id)
          state.form_model.price_items << _price_item
          set_state form_model: state.form_model
        end

      end
    end
  end
end