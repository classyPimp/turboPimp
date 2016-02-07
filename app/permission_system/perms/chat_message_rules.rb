module Perms      
  class ChatMessageRules < Perms::Base

    def create
      @serialize_on_success = 
      {

      }
      @serialize_on_error = 
      {
        moethods: [:errors]
      }
    end

    def index
      @serialize_on_success = 
      {
        include:
        [
          chat_messages:
          {
            root: true
          }
        ]
      }
    end

    def appointment_scheduler_create
      if @current_user && @current_user.has_role?(:appointment_scheduler)
        @serialize_on_success =
        {

        }
        @serialize_on_error =
        {
          methods: [:erros]
        }
      end
    end

    def appointment_scheduler_index
      if @current_user && @current_user.has_role?(:appointment_scheduler)
        @serialize_on_success = 
        {
          include:
          [
            {
              si_user1id_email_registered:
              {
                root: true,
                include:
                [
                  si_profile1id_name: 
                  {
                    root: true
                  }
                ]
              }
            },
            {
              chat_messages:
              {
                root: true
              }
            }
          ]
        }
      end
    end

    def poll_index
      if @current_user
        true
      end
    end

    def appointment_scheduler_poll_index
      if @current_user && @current_user.has_role?(:appointment_scheduler)
        @serialize_on_success =
        {
          include:
          [
            {
              si_user1id_email_registered:
              {
                root: true,
                include:
                [
                  si_profile1id_name:
                  {
                    root: true
                  }
                ]
              }
            },
            {
              si_chat_messages1after_id:
              {
                root: true
              }
            }
          ]
        }
      end
    end

  end
end