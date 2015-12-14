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


  #***********************
    def index
      per_page = params[:per_page] || 25

      if @current_user && @current_user.has_any_role?(:admin, :root)

        @model = ::User.includes(:profile_id_name, :avatar, :roles).all.paginate(page: params[:page], per_page: per_page)
        
        @model = @model.as_json(
          only:    ::User::EXPOSABLE_ATTRIBUTES,
          include: {
            avatar:  { root: true, only: [:id], methods: [:url]},
            profile: { root: true, only: [:id,  :name]},
            roles: { root: true, only: [:name] }
          }
        ) << @controller.extract_pagination_hash(@model)
      
      else  

        @model = User.includes(:profile_id_name, :avatar).all.paginate(page: params[:page], per_page: 10)

        @model = @model.as_json(
          only:    User::EXPOSABLE_ATTRIBUTES,
          include: {
            avatar:  { root: true, only: [:id], methods: [:url] },
            profile: { root: true, only: [:id,  :name]}
          }
        ) << @controller.extract_pagination_hash(@model)

      end
      
    end    
  #********************

    def destroy
      @current_user && @current_user.has_any_role?(:admin, :root)
    end

    def update
      if ::User.find(params[:id]).id == @current_user.try(:id)
        @permitted_attributes = params.require(:user).permit(:email, :password, :password_confirmation, avatar_attributes: [:file, :id, :user_id], profile_attributes: [:name, :bio, :id, :user_id])
      else
        false
      end
    end

  end
end