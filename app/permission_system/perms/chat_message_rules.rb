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
      serialize_on_success = 
      {
        
      }
    end

  end
end