require "controllers/base_controller"

class AppController < BaseController

	class << self
		attr_accessor :login_info_component
	end

	def self.check_credentials
		li = Helpers::Cookie.get("l=")
		if li && (lic = @login_info_component) && !CurrentUser.logged_in
			lic.request_credentials
		end	
	end

  def self.logout_user
    CurrentUser.logout.then do |r|
    	if lic = @login_info_component
    		lic.on_user_logout
    	end
      App.history.replaceState(nil, "/users/login")
    end.fail do |r|
      p "logout failed"
    end
  end

  def self.user_logged_in 
  	p "#{self} user_logged_in"
  	if lic = @login_info_component
  		lic.update_current_user
  	end
  end

end