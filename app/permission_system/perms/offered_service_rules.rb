module Perms
  class OfferedServiceRules < Perms::Base

    def admin_create
      if @current_user && @current_user.has_role?(:admin)
        return true
      end
    end

  end
end