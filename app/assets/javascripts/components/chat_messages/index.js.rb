module Components
  module ChatMessages
    class Index < RW
      expose

      include Plugins::Formable
      
      def get_initial_state
        @last_message_id = 0
        {
          chat: Chat.new,
          form_model: ChatMessage.new,
          expanded: false
        }
      end

      def component_did_mount
        if CurrentUser.user_instance.id
          ChatMessage.index.then do |chat|
            begin
            p chat
            if chat
              @last_message_id = chat.chat_messages[-1].id
              prepare_message_display_side(chat)
              set_state chat: chat  
            else
              p "is empty: #{chat}"
            end
            rescue Exception => e
              p e
            end
          end
        end
      end

      def render
        t(:span, {className: "chat_messages_index #{state.expanded ? 'chat_expanded' : 'chat_not_expanded'}"},
          if state.expanded
            t(:div, {className: "client_chat_message_box well"},
              *if state.chat.chat_messages.length > 0
                [
                  t(:button, {className: 'btn btn-xs btn-primary', onClick: ->{chat_toggle_expand}}, 'X close'),
                  *splat_each(state.chat.chat_messages) do |message|
                    t(:div, {className: "message #{message_side(message)}"},
                      t(:p, {}, "#{message.text}"),
                      t(:p, {className: "message_time"}, "#{Moment.new(message.attributes[:created_at]).format('YY.MM.DD HH:mm')}")
                    )
                  end
                ]
              else
                [
                  t(:button, {className: 'btn btn-xs btn-primary pull-right', onClick: ->{chat_toggle_expand}}, 'X close'),
                  t(:p, {}, 'no messages yet. Want to ask something? go ahed, our stuff will reply you')
                ]
              end,
              t(:div, {className: 'input_and_submit_button'},
                input(Forms::Input, state.form_model, :text),
                t(:button, {className: 'btn btn-primary submit_button',onClick: ->{submit_message}}, 'submit')
              )
            )
          else
            t(:button, {className: 'btn btn-primary chat_button', onClick: ->{chat_toggle_expand}},
              'press here to chat with us realtime'
            )
          end
        )
      end

      def submit_message
        collect_inputs
        unless state.form_model.has_errors?
          state.form_model.create.then do |model|
            begin 
            if model.has_errors?
              set_state form_model: model
            else
              set_state form_model: ChatMessage.new(text: '')
              start_polling unless @message_poller
            end
          rescue Exception => e
            p e
          end
          end
        else
          alert 'server error occured'
          set_state form_model: state.form_model
        end
      end

      def start_polling
        @message_poller = Services::MessagesPoller.new(3000) do
          ChatMessage.poll_index(payload: {last_id: @last_message_id}).then do |messages_and_users|
            begin
            self.update_messages(messages_and_users)
            rescue Exception => e
              p e
            end
          end
        end
        @message_poller.start
      end

      def component_will_unmount
        @message_poller.stop if @message_poller
      end

      def update_messages(messages_and_users)
        begin
        p messages_and_users
        if messages_and_users[:chat_messages] && messages_and_users[:chat_messages].length > 0
          p 'gon set last message'
          @last_message_id = messages_and_users[:chat_messages][-1].id
          p "last message set to : #{@last_message_id}"
          messages_and_users[:users].each do |user|

          end
          state.chat.chat_messages = state.chat.chat_messages + messages_and_users[:chat_messages]
          set_state chat: state.chat
        end
      rescue Exception => e
        p e
      end

      end 

      def chat_toggle_expand
        set_state expanded: !state.expanded             
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
        @side[:left] = true
        @side[:right] = true
      end 

      def message_side(message)
        side = 'left'
        if @side[:left] == message.user_id 
          side = 'left'
        else
          side = 'right'
        end 
      end

    end
  end
end