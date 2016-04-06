module Components 
  module AppointmentSchedulers
    module ChatMessages
      class Index < RW
        expose

        def init
          @last_message_id = 0
          @cache_holder = Hash.new { |hash, key| hash[key] =  Chat.new(id: key)}
        end

        def get_initial_state
          {
            chats: ModelCollection.new, 
            active_chat_id: false
          }
        end

        def component_did_mount
          ChatMessage.index(namespace: 'appointment_scheduler').then do |chats|
          begin

            self.prepare_cache_holder_and_last_message(chats)

            set_state chats: @cache_holder

            @message_poller = Services::MessagesPoller.new(3000) do
              ChatMessage.poll_index(namespace: 'appointment_scheduler', payload: {last_id: @last_message_id}).then do |chats|
                begin
                self.update_messages(chats)
                rescue Exception => e
                  p e
                end
              end
            end
            @message_poller.start

          rescue Exception => e
            p e
          end
          end
        end

        def prepare_cache_holder_and_last_message(chats)

          last_messages = []
          chats.each do |chat|
            @cache_holder[chat.id] = chat
            last_messages << chat.chat_messages[-1].id
          end
          if last_messages.length > 0
            @last_message_id = last_messages.sort[-1]
          end

        end

        def update_messages(chats)

          chats.each do |chat|
            if @cache_holder[chat.id].chat_messages.length > 0
              @cache_holder[chat.id].chat_messages = @cache_holder[chat.id].chat_messages + chat.chat_messages
            else
              @cache_holder[chat.id] = chat
            end
            if @last_message_id < chat.chat_messages[-1].id
              @last_message_id = chat.chat_messages[-1].id
            end
          end
          set_state chats: @cache_holder

        end

        def component_will_unmount
          @message_poller.stop if @message_poller
        end

   
        def render

          t(:div, {},
            t(:div, {className: 'row'},
              t(:div, {className: 'col-lg-4'},
                *splat_each(state.chats) do |k, chat|
                  t(:div, {},
                    t(:div, {className: "user_info"}, 
                      t(:p, {}, "for #{chat.user.id}:"),
                      if !chat.user.attributes[:registered]
                        t(:p, {className: 'unregistered_disclaimer'}, 'unregistered')
                      end,
                      if chat.user.profile.try(:name)
                        t(:p, {}, chat.user.profile.name)
                      else
                        t(:p, {}, '-')
                      end
                    ),
                    t(:p, {}, count_new_messages(chat.chat_messages)),
                    t(:button, {onClick: ->{chat_with(chat)}}, 'chat'),
                    t(:button, {onClick: ->{destroy_chat(chat)}}, 'delete this chat')
                  )
                end
              ),
              t(:div, {className: 'col-lg-8'},
                if state.active_chat_id
                  t(Components::AppointmentSchedulers::ChatMessages::ActiveChat, {chat: state.chats[state.active_chat_id],
                                                                        on_message_sent: event(->(message){self.on_message_sent(message)}, index: self)})
                else
                  'no active chat'
                end
              )            
            )
          )
        end

        def chat_with(chat)
          set_state active_chat_id: chat.id
        end

        def count_new_messages(messages)
          counter = 0
          messages.each do |message|
            if !message.read && !message.to_user
              counter += 1
            end
          end
          counter
        end

        def on_message_sent(message)
          # should add immediately or better wait when by poller?
          # state.users_and_messages[message.user_id][:messages] << message
          # set_state users_and_messages: state.users_and_messages
        end

        def destroy_chat(chat)
          chat.destroy(namespace: 'appointment_scheduler').then do |_chat|
            state.chats.remove(chat)
            set_state chats: state.chats
          end
        end

      end
    end
  end
end