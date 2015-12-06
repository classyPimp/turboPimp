module Perms
  class User < Perms::Base

    def create
      if @controller.params[:user][:role]
        @permitted_attributes = @controller.params.require(:user).
              permit(:email, :password, :password_confirmation, avatar_attributes: [:file], profile_attributes: [:name, :bio] )
        @current_user.has_role? :admin
      else
        @permitted_attributes = @controller.params.require(:user).permit(:email, :password, :password_confirmation)
      end      
    end

  end
end