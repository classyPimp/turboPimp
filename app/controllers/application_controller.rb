class ApplicationController < ActionController::Base
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include Perms::ControllerMethods
  rescue_from Perms::Exception, with: :user_not_authorized
  #AUTHENTICATION
	include SessionsHelper
	#END AUTHENTICATION

  #will paginate. To not manually type this repeating stuff
  def extract_pagination_hash(model)
    {pagination: {current_page: model.current_page, total_entries: model.total_entries, total_pages: model.total_pages,
              offset: model.offset}}    
  end

 private

	#this method is used for handling Pundit::NotAuthorizedError exception
	def user_not_authorized
		head 403
	end


end
