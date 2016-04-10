module Perms      
  class ChatRules < Perms::Base

    def appointment_scheduler_destroy
      if @current_user && @current_user.has_role?(:appointment_scheduler)
        return true
      end
    end

  end
end