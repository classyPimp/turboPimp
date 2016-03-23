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

    def admin_destroy
      if @current_user && @current_user.has_role?(:admin)
        true
      end
    end

    def admin_update
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
