class SessionsController < ApplicationController

  def new
  end
  ####################AUTHENTICATION
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if User::ACTIVATABLE
        if user.activated?
          log_in user
          params[:session][:remember_me] == '1' ? remember(user) : forget(user)
          cookies[:l] = user.id
          render json: user.as_json(only: [:id, :email])
        else
          render json: {errors: ["not activated"]}
        end
      else
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        render json: user.as_json(only: [:id, :email])
      end
    else  
      flash.now[:danger] = "invalid credentials"
      render json: {errors: ["invalid credentials"]}
    end
  end

  def destroy
    log_out if logged_in?
    render json: {status: "ok"}
  end
  ####################END AUTHENTICATION
end
