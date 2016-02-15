module Perms
  class PriceCategoryRules < Perms::Base 
  
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

    def admin_index
      if @current_user && @current_user.has_role?(:admin)
        @serialize_on_success =
        {
          include:
          [
            {
              price_items:
              {
                root: true
              }
            }
          ]
        }
      end
    end
    
    def admin_destroy
      if @current_user && @current_user.has_role?(:admin)
        true
      end
    end

  end
end
