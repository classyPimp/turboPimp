module Components
  module Admin
    module PriceCategories
      class New < RW
        expose  

        include Plugins::Formable

        def validate_props
          unless props.on_price_category_created && props.on_price_category_created.is_a?(ProcEvent)
            p '==========================PROPS ERRORS================='
            p "#{self.class.name}#{self} props.on_price_category_created should be of ProcEvent instance,
            but #{props.on_price_category_created} was passed"
          end
        end

        def get_initial_state
          {
            form_model: PriceCategory.new
          }
        end

        def render
          t(:div, {},
            input(Forms::Input, state.form_model, :name),
            t(:button, {onClick: ->{handle_inputs}}, 'create')
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
                set_state form_model: PriceCategory.new
                emit(:on_price_category_created, model)
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