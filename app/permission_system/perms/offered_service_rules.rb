module Perms
  class OfferedServiceRules < Perms::Base

    def admin_create
      if @current_user && @current_user.has_role?(:admin)
        return true
      end
    end

    def admin_edit
      if @current_user && @current_user.has_role?(:admin)
        @serialize_on_success =
        {
          include: 
          [
            {
              avatar:
              {
                root: true
              }
            },
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

    def index
      @serialize_on_success = 
      {
        include:
        [
          si_price_items1id_name_price:
          {
            root: true
          },
          avatar:
          {
            root: true,
            methods: 
            [
              :url
            ]
          }
        ]
      }
    end

  end
end