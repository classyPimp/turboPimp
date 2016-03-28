module Components
  module Admin
    module PriceItems
      class New < RW
        expose

        include Plugins::Formable
        
        def validate_props
          unless props.on_price_item_created && props.on_price_item_created.is_a?(ProcEvent)
            p "#{self.class.name}#{self} props.on_price_item_created should be of ProcEvent, instead #{props.on_price_item_created} was passed"
          end

          unless props.on_price_item_new_cancel && props.on_price_item_new_cancel.is_a?(ProcEvent)
            p "#{self.class.name}#{self} props.on_price_item_new_cancel should be of  ProcEvent, instead #{props.on_price_item_created} was passed"
          end

          unless props.price_category && props.price_category.is_a?(PriceCategory)
            p "#{self.class.name}#{self} props.price_category should be PriceCategory instance, instead #{props.price_category} was passed"
          end

        end

        def get_initial_state
          {
            form_model: PriceItem.new(price_category_id: "#{props.price_category.id}")
          }          
        end

        def render
          t(:div, {},
            input(Forms::Input, state.form_model, :name),
            input(Forms::Input, state.form_model, :price),
            t(:button, {onClick: ->{handle_inputs}}, 'create'),
            t(:button, {onClick: ->{cancel_inputs}}, 'cancel')
          )
        end

        def handle_inputs
          collect_inputs
          if state.form_model.has_errors?
            set_state form_model: state.form_model
          else
            state.form_model.create(namespace: 'admin').then do |model|
              begin 
              if model.has_errors?
                set_state form_model: model
              else
                emit(:on_price_item_created, model)
              end
              rescue Exception => e
                p e
              end
            end
          end

        end

        def cancel_inputs
          emit(:on_price_item_new_cancel, props.price_category)
        end

      end
    end
  end
end
