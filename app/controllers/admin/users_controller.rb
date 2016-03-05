class Admin::UsersController < ApplicationController

  def show

    @perms = perms_for :User

    auth! @perms.admin_show

    render json: @perms.model

  end

  def index


    @perms = perms_for :User  

    auth! @perms.admin_index

    page = params[:page]
    per_page = params[:per_page] || 25
    search_query = params[:search_query]
    roles = params[:roles]
    registered_only = params[:registered_only]
    unregistered_only = params[:unregistered_only]
    chat_only = params[:chat_only]  

    if !search_query.blank?

      @users = User.user_search(search_query)

    else

      @users = User.all
    
    end

    unless roles.blank?

      @users = @users.joins(:roles).where('roles.name in ?', roles)

    end

    unless registered_only.blank?

      @users = @users.where(registered: true)

    end

    unless unregistered_only.blank?

      @users = @users.where(registered: false)

    end

    if chat_only

      other_roles = Services::RoleManager.allowed_global_roles
      other_roles.delete('from_chat')
      @users.joins(:roles).where('roles.name = ?', 'from_chat').where('roles.name not in ?', other_roles)

    end

    @users = @users.select('users.id, users.email')

    @users = @users.paginate(per_page: per_page, page: page)

    @users = @users.as_json(@perms.serialize_on_success) << self.extract_pagination_hash(@users)

    render json: @users

  end

  def create

    perms_for :User #added !standart_auth
    auth! @perms.admin_create #added !standart_auth
    #render json: @perms.permitted_attributes and return
    @user = User.new(@perms.permitted_attributes)

    if @user.save
      render json: @user.as_json(only: [:id, :email])
    else
      render json: @user.as_json(
        only: [],
        include: [
        {profile: {root: true, only: [], methods: [:errors]}}, 
        {roles: {root: true, only: [], methods: [:errors]}}, 
        {avatar: {root: true, only: [], methods: [:errors]}}
        ])
    end

  end

  def edit
    
    @perms = perms_for :User

    auth! @perms.admin_edit

    render json: @perms.model

  end

  def update
    @perms = perms_for :User

    auth! @perms.admin_update

    @user = User.find(params[:id])

    @user.update_attributes(@perms.permitted_attributes)
    if @user.save
      render json: @user.as_json(only: [:email, :id], 
                                include: {profile: {root: true, only: [:id, :name, :bio, :user_id]},
                                          avatar: {root: true, only: [:id], methods: [:url]}})
    else  
       render json: @user.as_json(only: [:email, :id], methods: [:errors], 
                                include: {profile: {root: true, only: [:id, :user_id, :name, :bio]},
                                          avatar: {root: true, only: [:id], methods: [:url]}})
    end
  end

end
