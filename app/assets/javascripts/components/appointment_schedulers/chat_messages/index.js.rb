module Components
  module AppointmentSchedulers
    module ChatMessages
      class Index < RW
        expose

        def get_initial_state
          {
            users_with_messages: ModelCollection.new
          }
        end

        def component_did_mount
          ChatMessage.index(namespace: 'appointment_scheduler').then do |users|
          begin
            last_messages_holder = []
            users.each do |u|
              last_messages_holder << u.chat_messages[-1].attributes[:created_at]
            end

            last_messages_holder.sort!
            @lastmessage = last_messages_holder[-1]

            set_state users_with_messages: users

            x = Services::MessagesPoller.new(3000) do
              p Moment.new
            end
            x.start

          rescue Exception => e
            p e
          end
          end
        end

        def render
          t(:div, {},
            *splat_each(state.users_with_messages) do |user|
              t(:div, {}, 
                t(:p, {}, "#{user.id}"),
                if user.profile && user.profile.attributes[:name]
                  t(:p, {}, "#{user.profile.name}")
                end,
                unless user.attributes[:registered]
                  t(:p, {}, "unregistered")
                end,
                if user.profile && user.profile.phone_number
                  t(:p, {}, "#{users.phone_number}")
                end,
                *splat_each(user.chat_messages) do |message|
                  t(:p, {}, "#{message.text} : #{message.attributes[:created_at]}")
                end,
                t(:br, {})
              )
            end
          )
        end

      end
    end
  end
end