module Perms
  class PriceItemRules < Perms::Base 
  
    def admin_create
      if @current_user && @current_user.has_role?(:admin)
        @serialize_on_success = 
        {

        }
        @serialize_on_error =
        {
          methods: [:errors]
        }
      end
    end    


      
  end
end
