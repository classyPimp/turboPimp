module Components
  module ChatMessages
    class Index < RW
      expose

      include Plugins::Formable
      
      def get_initial_state
        {
          chat: Chat.new,
          form_model: ChatMessage.new
        }
      end

      def component_did_mount
        if CurrentUser.user_instance.id
          ChatMessage.index.then do |chat|
            if chat
              set_state chat: chat  
            else
              p "is empty: #{chat}"
              return
            end
            
          end
        end
      end

      def render
        t(:div, {},
          *splat_each(state.chat.chat_messages) do |message|
            t(:p, {}, "#{message.text} : #{message.attributes[:created_at]}")
          end,
          input(Forms::Input, state.form_model, :text),
          t(:button, {onClick: ->{submit_message}}, 'submit')
        )
      end

      def submit_message
        collect_inputs
        unless state.form_model.has_errors?
          state.form_model.create.then do |model|

            if model.has_errors?
              set_state form_model: model
            else
              set_state form_model: ChatMessage.new
              @last_message_id = model.id
              start_polling unless @message_poller
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
        @message_poller.stop if @message.poller
      end

      def update_messages(messages_and_users)
        if messages_and_users[:messages] && messages_and_users[:messages].length > 0
          @last_message_id = messages_and_users.messages
          state.chat.chat_messages = state.chat.chat_messages + messages.data
          set_state chat: state.chat
        end
      end

      

    end
  end
end