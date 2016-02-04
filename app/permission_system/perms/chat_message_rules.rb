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
          only: [:id, :registered],
          include: 
          [
            {
              chat_messages:
              {
                root: true
              }
            },
            {
              si_profile1name_phone_number:
              {
                root: true
              }
            }
          ]
        }
      end
    end

    def appointment_scheduler_poll_index
      if @current_user && @current_user.has_role?(:appointment_scheduler)
        @serialize_on_success =
        {
          only: [:id, :registered],
          include: 
          [
            {
              chat_messages:
              {
                root: true
              }
            },
            {
              si_profile1name_phone_number:
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