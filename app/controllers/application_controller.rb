class ApplicationController < ActionController::Base
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include Perms::ControllerMethods
  rescue_from Perms::Exception, with: :user_not_authorized
  #AUTHENTICATION
	include SessionsHelper
	#END AUTHENTICATION

 private

	#this method is used for handling Pundit::NotAuthorizedError exception
	def user_not_authorized
		head 403
	end
end
