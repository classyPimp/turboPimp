class UsersController < ApplicationController

=begin
IMPORTANT NOTICE
don't forget to insert this into application_controller
<div class="container">
  <div class="row-offset-3">
  <%= render "sessions/user_bar" %>
</div>
<% flash.each do |message_type, message| %>
  <div class="alert alert-<%= message_type %>"><%= message %></div>
<% end %>
=end
  before_action :logged_in_user, only: [:edit, :update]
  before_action :correct_user,   only: [:edit, :update]

  def show
    @user = User.find params[:id]
  end

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
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def expose_current_user
    unless current_user == nil
      render json: current_user.as_json(only: [:id, :email])
    else
      render json: {user: {status: "guest"}}
    end
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
end
