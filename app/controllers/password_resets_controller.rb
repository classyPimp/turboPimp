class PasswordResetsController < ApplicationController
  # => ##################AUTHENTICATION
  before_action :get_user         , only: [:edit , :update]
  before_action :valid_user       , only: [:edit , :update]
  before_action :check_expiration , only: [:edit , :update]

  def new
    
  end

  def create
    @user =User.find_by email: params[:password_reset][:email].downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      render json: {status: "ok"}
    else
      render json: {errors: ["error occured"]}, status: 400
    end
  end

  def edit
    
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty")
      render json: @user.as_json(only: [:errors]), status: 400
    elsif @user.update_attributes(user_params)
      log_in @user
      render json: @user.as_json(only: [:id, :email])
    else
      render json: {user: {errors: ["fuck! occured"]}}
    end
  end

 private
  
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end


  def get_user
    @user = User.find_by email: params[:email]
  end 

  def valid_user
    unless (  @user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]) )
      render json: {user: {errors: [params]}}     
    end
  end

  def check_expiration
    if @user.password_reset_expired?
      render json: {errors: "reset expired"}
      redirect_to new_password_reset_url
    end
  end

  # => ##################END AUTHENTICATION
end
