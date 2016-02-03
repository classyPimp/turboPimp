module Components
  module ChatMessages
    class Index < RW
      expose

      include Plugins::Formable
      
      def get_initial_state
        {
          chat_messages: ModelCollection.new,
          form_model: ChatMessage.new
        }
      end

      def component_did_mount
        if CurrentUser.user_instance.id
          ChatMessage.index.then do |chat_messages|
            set_state chat_messages: chat_messages
          end
        end
      end

      def render
        t(:div, {},
          *splat_each(state.chat_messages) do |message|
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
              CurrentUser.user_instance.id = model.user_id
              state.chat_messages << model
              set_state chat_messages: state.chat_messages, form_model: ChatMessage.new
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