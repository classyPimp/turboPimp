module Components
  module Admin 
    module PriceItems
      class Edit < RW
        expose

        include Plugins::Formable

        def get_initial_state
          {
            form_model: props.form_model
          }
        end

        def render
          t(:div, {className: 'price_item_edit'}, 
            input(Forms::Input, state.form_model, :name, {show_name: 'name'}),
            input(Forms::Input, state.form_model, :price, {show_name: 'price'}),
            t(:button, {onClick: ->{handle_inputs}}, 'save changes'),
            t(:button, {onClick: ->{emit(:on_price_item_edit_cancel)}}, 'cancel')
          )
        end

        def handle_inputs
          collect_inputs
          if state.form_model.has_errors?
            set_state form_model: state.form_model
          else
            state.form_model.update(namespace: 'admin').then do |model|
              begin 
              if model.has_errors?
                set_state form_model: model
              else
                emit(:on_price_item_updated, model)
              end
              rescue Exception => e
                p e
              end
            end
          end          
        end

      end
    end
  end
end