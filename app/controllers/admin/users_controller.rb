class Admin::UsersController < ApplicationController

  def show

    @perms = perms_for :User

    auth! @perms.admin_show

    render json: @perms.model

  end

  def index

    @perms = perms_for :User

    auth! @perms.admin_index

    render json: @perms.model

  end

  def create

    perms_for :User #added !standart_auth
    auth! @perms.admin_create #added !standart_auth
    #render json: @perms.permitted_attributes and return
    @user = User.new(@perms.permitted_attributes)

    if @user.save
      render json: @user.as_json(only: [:id, :email])
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
