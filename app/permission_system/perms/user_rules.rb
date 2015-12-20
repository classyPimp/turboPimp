module Perms
  class UserRules < Perms::Base

    def create
      @permitted_attributes = @controller.params.require(:user).permit(:email, :password, :password_confirmation, profile_attributes: [:name, :bio], avatar_attributes: [:file])      
    end
  #********************

    def admin_create
      if @controller.current_user && @controller.current_user.has_any_role?(:admin, :root)
        @permitted_attributes = @controller.params.require(:user).
              permit(:email, :password, :password_confirmation, avatar_attributes: [:file], 
                      profile_attributes: [:name, :bio], roles_attributes: [:name] )
        
      end
    end


  #***********************
    def index
      per_page = params[:per_page] || 25

      
        @model = ::User.includes(:profile_id_name, :avatar).all.paginate(page: params[:page], per_page: per_page)

        @model = @model.as_json(
          only:    ::User::EXPOSABLE_ATTRIBUTES,
          include: {
            avatar:  { root: true, only: [:id], methods: [:url] },
            profile: { root: true, only: [:id,  :name]}
          }
        ) << @controller.extract_pagination_hash(@model)
      
    end    
  #********************

    def admin_index

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
      end
      
    end

  #***********

    def destroy
      @current_user.has_any_role?(:admin, :root)
    end

  #*********************

    def update
      if ::User.find(params[:id]).id == @current_user.try(:id)
        @permitted_attributes = params.require(:user).permit(:email, :password, :password_confirmation, avatar_attributes: [:file, :id, :user_id], profile_attributes: [:name, :bio, :id, :user_id])
      end
    end

  #********************

    def admin_update
      if @current_user.has_any_role? :admin, :root
        @permitted_attributes = params.require(:user).permit(:email, :password, :password_confirmation, 
                                                              avatar_attributes: [:file, :id, :user_id], 
                                                              profile_attributes: [:name, :bio, :id, :user_id],
                                                              roles_attributes: [:name, :id, :user_id, :_destroy])        
      end
    end


  #**************
    
    def show

      @model = ::User.includes(:profile, :avatar).find(@controller.params[:id])

      @model = @model.as_json(
        only:  ::User::EXPOSABLE_ATTRIBUTES,
        include: {
          avatar:  { root: true, only: [:id, :user_id], methods: [:url] },
          profile: { root: true, only: [:id,  :name, :bio, :user_id]}
        }
      )

      @model    

    end

    def admin_show
      if @current_user && @current_user.has_role?(:admin)

        @model = ::User.includes(:profile, :avatar, :roles).find(@controller.params[:id])

        @model = @model.as_json(
          only:    ::User::EXPOSABLE_ATTRIBUTES,
          include: {
            avatar:  { root: true, only: [:id, :user_id], methods: [:url]},
            profile: { root: true, only: [:id,  :name, :bio, :user_id]},
            roles: { root: true, only: [:name] }
          }
        )

        @model
      end
    end

  #********************

    def edit
      if @current_user.id.to_s == params[:id]
        @model = ::User.includes(:profile, :avatar).find(@controller.params[:id])

        @model = @model.as_json(
          only:  ::User::EXPOSABLE_ATTRIBUTES,
          include: {
            avatar:  { root: true, only: [:id, :user_id], methods: [:url] },
            profile: { root: true, only: [:id,  :name, :bio, :user_id]}
          }
        )

        @model    
      end
    end

    def admin_edit
      
      if @current_user && @current_user.has_role?(:admin)

        @model = ::User.includes(:profile, :avatar, :roles).find(@controller.params[:id])

        @model = @model.as_json(
          only:    ::User::EXPOSABLE_ATTRIBUTES,
          include: {
            avatar:  { root: true, only: [:id, :user_id], methods: [:url]},
            profile: { root: true, only: [:id,  :name, :bio, :user_id]},
            roles: { root: true, only: [:name, :id] }
          }
        )

        @model
      end
    end


  end
end