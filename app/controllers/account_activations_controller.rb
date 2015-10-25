class AccountActivationsController < ApplicationController

  def edit
      user = User.find_by(email: params[:email])
      if user && !user.activated? && user.authenticated?(:activation, params[:id])
        user.activate
        log_in user
        redirect_to "/users/activations?#{{id: user.id, email: user.email}.to_query}"
      else
        redirect_to "/users/activations?#{{status: "error"}.to_query}"
      end
  end 

end
