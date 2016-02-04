module Components
  module AppointmentSchedulers
    module ChatMessages
      class Index < RW
        expose

        def init
          @last_message_id = '0'
          @cache_holder = Hash.new { |hash, key| hash[key] = {user: nil, messages: []} }
        end

        def get_initial_state
          {
            users_and_messages: {}, 
            active_chat_id: false
          }
        end

        def component_did_mount
          ChatMessage.index(namespace: 'appointment_scheduler').then do |users_and_messages|
          begin

            self.prepare_cache_holder_and_last_message(users_and_messages)

            set_state users_and_messages: @cache_holder

            @message_poller = Services::MessagesPoller.new(3000) do
              ChatMessage.poll_index(namespace: 'appointment_scheduler', payload: {last_id: @last_message_id}).then do |users_and_messages|
                begin
                self.update_messages(users_and_messages)
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

        def prepare_cache_holder_and_last_message(users_and_messages)
          users = users_and_messages[:users]
          messages = users_and_messages[:messages]
          messages.each do |message|
            @cache_holder[message.user_id][:messages] << message
          end
          users.each do |user|
            @cache_holder[user.id][:user] = user
          end
          last_messages = []
          @cache_holder.each do |k,v|
            last_messages << v[:messages][-1].attributes[:id]
          end

          @last_message_id = last_messages.sort[-1]

        end

        def update_messages(users_and_messages)
          prepare_cache_holder_and_last_message(users_and_messages)
          set_state users_and_messages: @cache_holder
        end

        def component_will_unmount
          @message_poller.stop if @message_poller
        end

   
        def render
          t(:div, {},
            t(:div, {className: 'row'},
              t(:div, {className: 'col-lg-4'},
                *splat_each(state.users_and_messages) do |top_k, top_v|
                  t(:div, {},
                    t(:p, {}, "for #{top_v[:user].id}:"),
                    t(:p, {}, count_new_messages(top_v[:messages])),
                    t(:button, {onClick: ->{chat_with(top_v[:user])}}, 'chat')
                  )
                end
              ),
              t(:div, {className: 'col-lg-8'},
                if state.active_chat_id
                  t(Components::AppointmentSchedulers::ChatMessages::ActiveChat, {user: state.users_and_messages[state.active_chat_id][:user], 
                                                                        messages: state.users_and_messages[state.active_chat_id][:messages],
                                                                        on_message_sent: event(->(message){self.on_message_sent(message)})})
                else
                  'no active chat'
                end
              )            
            )
          )
        end

        def chat_with(user)
          set_state active_chat_id: user.id
        end

        def count_new_messages(messages)
          counter = 0
          messages.each do |message|
            if !message.read
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

      end
    end
  end
end