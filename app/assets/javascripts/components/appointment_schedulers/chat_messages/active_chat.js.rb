module Components
  module AppointmentSchedulers
    module ChatMessages
      class ActiveChat < RW

        expose

        include Plugins::Formable

        def get_initial_state
          {
            form_model: ChatMessage.new(chat_id: props.chat.id, to_user: props.chat.attributes[:user_id])
          }
        end

        def render
          t(:div, {}, 
            t(:p, {}, "user: #{props.chat.user.id}"),
            *splat_each(props.chat.chat_messages) do |message|
              t(:p, {}, message.text)
            end,
            input(Forms::Input, state.form_model, :text),
            t(:button, {onClick: ->{send_message}}, 'send')
          )          
        end

        def send_message
          collect_inputs
          unless state.form_model.has_errors?
            state.form_model.create(namespace: 'appointment_scheduler').then do |model|

              if model.has_errors?
                set_state form_model: model
              else
                emit(:on_message_sent, model)
                state.form_model.text = ''
              end

            end
          else
            alert 'server error occured'
            set_state form_model: state.form_model
          end
        end

      end
    end
  end
end