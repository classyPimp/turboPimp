class ApplicationController < ActionController::Base
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
	include SessionsHelper
	include Pundit

	rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

 private

	#this method is used for handling Pundit::NotAuthorizedError exception
	def user_not_authorized
		head 403
	end
end
