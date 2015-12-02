class UsersController < ApplicationController

  
  ######################AUTHENTICATION
  before_action :logged_in_user, only: [:edit, :update]
  before_action :correct_user,   only: [:edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(create_user_params)
    if @user.save
      if User::ACTIVATABLE
        @user.send_activation_email
        render json: @user.as_json(only: [:id, :email])
      else
        log_in @user
        #remember user
        render json: @user.as_json(only: [:id, :email])
      end
    else
      render json: {user: {errors: @user.errors}}
    end

  end

  def create_user_params
    #params.require(:user).permit(:email, :password, :password_confirmation) DEFAULT AUTHENTICATION. FOR PURE UNCOMMENT AND DELETE REST OF METHOD
    params.require(:user).permit(:email, :password, :password_confirmation, avatar_attributes: [:file], profile_attributes: [:name, :bio] )
  end

  # Confirms a logged-in user.
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  # Confirms the correct user.
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end
  ######################END AUTHENTICATION

  def expose_current_user
    unless current_user == nil
      render json: current_user.as_json(only: [:id, :email])
    else
      render json: {user: {status: "guest"}}
    end
  end

  def show
    @user = User.includes(:profile, :avatar).find params[:id]
    @response = @user.as_json(only: [:email, :id], 
                              include: {profile: {root: true, only: [:id, :name, :bio]},
                                        avatar: {root: true, only: [:id], methods: [:url]}})
    if @user == current_user
      @response["user"][:arbitrary] = "current_user"
    end
    render json: @response
  end
end
