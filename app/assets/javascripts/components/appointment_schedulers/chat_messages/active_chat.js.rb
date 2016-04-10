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
          if props.chat.chat_messages[0]
            prepare_message_display_side(props.chat) 
          end

          t(:div, {className: 'scheduler_chat_messages_index'}, 
            t(:p, {}, "user: #{props.chat.user.id}"),

            t(:div, {className: 'chat_messages_stack'},
              *splat_each(props.chat.chat_messages) do |message|
                t(:div, {className: "message #{message_side(message)}"},
                  if !message.to_user && !message.read
                    t(:p, {}, 'new')
                  end,
                  t(:p, {}, "#{message.text}"),
                  t(:p, {className: "message_time"}, "#{Moment.new(message.attributes[:created_at]).format('YY.MM.DD HH:mm')}")
                )
              end
            ),
            input(Forms::Input, state.form_model, :text, {}),
            t(:button, {onClick: ->{send_message}}, 'send'),
            t(:button, { onClick: ->{set_messages_read} }, 'set messages as read')
          )          
        end

        def component_did_mount
          set_messages_read
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

        def prepare_message_display_side(chat)
          @side = {}
          left = chat.chat_messages[0].user_id
          right = false
          chat.chat_messages.each do |chat_message|
            if chat_message.user_id == left
              next
            else
              right = chat_message.user_id
            end
          end
          @side[:left] = left
          @side[:right] = right
        end 

        def message_side(message)
          side = 'left'
          if @side[:left] == message.user_id 
            side = 'left'
          else
            side = 'right'
          end 
        end

        def set_messages_read
          messages_ids = props.chat.chat_messages.reduce([]) do |temp, c_m|
            if !c_m.to_user && !c_m.read
              temp << c_m.id
            end
            temp
          end
          unless messages_ids.empty?
            ChatMessage.set_read(payload: {ids: messages_ids}, namespace: 'appointment_scheduler').then do
              props.chat.chat_messages.each do |c_m|
                if messages_ids.include?(c_m.id)
                  c_m.read = true
                end 
              end
            end
          end
        end

      end
    end
  end
end