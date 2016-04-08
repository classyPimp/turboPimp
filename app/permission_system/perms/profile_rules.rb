module Perms
  class ProfileRules < Perms::Base 
  
    def update_phone_number
      if @current_user && (@current_user.id == @model.user_id)
        true
      end
    end

  end
end
