module Perms
  class RoleManager

    def roles_feed
      if @controller.current_user.has_any_role? :admin, :root
    end

  end
end