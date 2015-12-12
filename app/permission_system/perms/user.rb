module Perms
  class User < Perms::Base

    def create
      if @controller.current_user && @controller.current_user.has_any_role?(:admin, :root)
        @permitted_attributes = @controller.params.require(:user).
              permit(:email, :password, :password_confirmation, avatar_attributes: [:file], profile_attributes: [:name, :bio], roles_array: [] )
        @arbitrary = {as_admin: true, roles_array: @permitted_attributes.delete(:roles_array)}
        @current_user.has_any_role? :admin, :root
      else
        @permitted_attributes = @controller.params.require(:user).permit(:email, :password, :password_confirmation, profile_attributes: [:name, :bio], avatar_attributes: [:file])
      end      
    end

  end
end