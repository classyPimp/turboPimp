module Components
  module Admin  
    module OfferedServices
      class Edit < RW

        expose

        include Plugins::Formable
        include Plugins::DependsOnCurrentUser
        set_roles_to_fetch :admin

        def get_initial_state
          {
            form_model: false
          }        
        end

        def component_did_mount
          OfferedService.edit(component: self, wilds: {id: props.params.id}, namespace: 'admin').then do |offered_service|
            begin
            offered_service.avatar ? nil : (offered_service.avatar = OfferedServiceAvatar.new)
            set_state form_model: offered_service
            rescue Exception => e
              p e
            end
          end
        end

        def render
          t(:div, {className: 'offered_services_new'},
            if state.current_user.has_role?(:admin) && state.form_model
              t(:div, {}, 
                modal,
                progress_bar,
                input(Forms::Input, state.form_model, :title, {type: "text", show_name: 'title'}),
                input(Forms::Input, state.form_model, :m_title, {type: "text", show_name: 'meta title'}),
                input(Forms::Input, state.form_model, :m_description, {type: "text", show_name: 'meta description'}),
                input(Forms::Input, state.form_model, :m_keywords, {type: "text", show_name: 'meta keywords'}),
                t(:img, {src: state.form_model.avatar.try(:url)}),
                input(Forms::FileInputImgPreview, state.form_model.avatar, :avatar, {show_name: 'avatar'}),
                input(Forms::WysiTextarea, state.form_model, :body),
                t(:p, {}, 'associated price items'),
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
                ),
                t(:button, { onClick: ->{init_adding_associated_price_item}, className: 'btn btn-xs' }, '+add associated price item'),
                t(:button, {className: 'btn btn-primary', onClick: ->(){handle_inputs}}, "update")
              )
            end
          )
        end

        def handle_inputs
          collect_inputs
          unless state.form_model.has_errors?
            state.form_model.update(serialize_as_form: true, namespace: 'admin', comoponent: self).then do |model|
              if model.has_errors?
                set_state form_model: model
              else
                create_flash('service has been udpated')
                #state.form_model = model
                props.history.pushState(nil, '/users/dashboard')
              end
            end
          else
            set_state form_model: state.form_model
          end
        end

        # def start_new
        #   set_state form_model: Blog.new
        # end

        def remove_associated_price_item(price_item)
          price_item.attributes['_destroy'] = '1'
          set_state form_model: state.form_model
        end

        def init_adding_associated_price_item
          modal_open(
            'choose price item to associate',
            t(Components::Admin::Prices::Index, {as_model_provider: true, add_associated_price_item: event(->(price_item){add_associated_price_item(price_item)})})
          )
        end

        def add_associated_price_item(price_item)
          
          already_assigned = false
          state.form_model.price_items.each do |p_i|
            if p_i.id == price_item.id
              already_assigned = p_i
              break
            end
          end

          if already_assigned
            already_assigned.attributes.delete('_destroy')
          else
            _price_item = PriceItem.new(id: price_item.id, name: price_item.name)
            state.form_model.price_items << _price_item
          end
          
          set_state form_model: state.form_model
          
        end

      end
    end
  end
end