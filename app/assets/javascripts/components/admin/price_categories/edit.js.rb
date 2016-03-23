module Components
  module Admin
    module PriceCategories
      class Edit < RW
        expose

        include Plugins::Formable

        def get_initial_state
          {
            form_model: props.form_model
          }
        end

        def render
          t(:div, {className: 'price_category_edit'}, 

            input(Forms::Input, state.form_model, :name, {show_name: 'name'}),
            t(:button, {className: 'btn btn-default',onClick: ->{handle_inputs}}, 'save changes'),
            t(:button, {className: 'btn btn-default', onClick: ->{emit(:on_price_category_edit_cancel)}}, 'cancel' )


          )
        end

        def handle_inputs
          collect_inputs
          if state.form_model.has_errors?
            set_state form_model: state.form_model
          else
            state.form_model.update(namespace: 'admin').then do |model|
              if model.has_errors?
                set_state form_model: model
              else
                state.form_model.name = model.name
                emit(:on_price_category_updated, state.form_model)
              end
            end
          end
        end

      end
    end
  end
end