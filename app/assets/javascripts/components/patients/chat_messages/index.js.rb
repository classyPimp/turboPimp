module Components
  module Patients
    module ChatMessages
      class Index < RW
        expose

        include Plugins::Formable
      
        def get_initial_state
          @chat_id = 0
          @last_message_id = 0
          {
            chat: Chat.new,
            form_model: ChatMessage.new,
            progress_bar: false
          }
        end

        def component_did_mount
          if CurrentUser.user_instance.id
            ChatMessage.index.then do |chat|
              begin
              if chat
                @last_message_id = chat.chat_messages[-1].id || 0
                prepare_message_display_side(chat)
                set_state chat: chat  
              else
                nil
              end
              rescue Exception => e
                p e
              end
            end
          end
        end

        def render
          if state.chat.chat_messages[0]
            prepare_message_display_side(state.chat) 
          end
          t(:span, {className: "scheduler_chat_messages_index chat_expanded"},
            t(:div, {className: "client_chat_message_box well"},
              if state.progress_bar
                t(Shared::ThinProgressBar, {ref: 'progress_bar', interval: 500, className: 'chat_progress'})
              end,
              *if state.chat.chat_messages.length > 0
                [
                  t(:div, {className: 'chat_messages_stack'},
                    *splat_each(state.chat.chat_messages) do |message|
                      t(:div, {className: "message #{message_side(message)}"},
                        t(:p, {}, "#{message.text}"),
                        t(:p, {className: "message_time"}, "#{Moment.new(message.attributes[:created_at]).format('YY.MM.DD HH:mm')}")
                      )
                    end
                  )
                ]
              else
                [
                  t(:p, {}, 'no messages yet. Want to ask something? go ahed, our stuff will reply you')
                ]
              end,
              t(:div, {className: 'input_and_submit_button'},
                input(Forms::Input, state.form_model, :text, {reset_value: true}),
                t(:button, {className: 'btn btn-primary submit_button',onClick: ->{submit_message}}, 'submit')
              )
            )
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
                set_state form_model: ChatMessage.new(text: ''), progress_bar: true
                @chat_id = model.attributes[:chat_id]
                start_polling unless @message_poller
                self.progress_bar.start_interval_update
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

            ChatMessage.poll_index(payload: {last_id: @last_message_id, chat_id: @chat_id}).then do |messages_and_users|
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

          progress_bar.set_full_width if progress_bar

          if messages_and_users[:chat_messages] && messages_and_users[:chat_messages].length > 0

            @last_message_id = messages_and_users[:chat_messages][-1].id
            @chat_id = messages_and_users[:chat_messages][-1].attributes[:chat_id]

            p "last_message_id = #{@last_message_id}"
            # messages_and_users[:users].each do |user|

            # end

            state.chat.chat_messages = state.chat.chat_messages + messages_and_users[:chat_messages]

            set_state chat: state.chat

          end

          progress_bar.reset_width if progress_bar

        rescue Exception => e
          p e
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

        def message_unread?(message)
          if message.user_id.to_i == CurrentUser.user_instance.id.to_i && !message.read
            true
          end
        end

        def progress_bar
          ref('progress_bar').rb
        end

      end
    end
  end
end