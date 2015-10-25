require "controllers/base_controller"

class AppController < BaseController

	class << self
		attr_accessor :login_info_component, :logged_in
	end

	def self.check_credentials
		li = Helpers::Cookie.get("l=")
		if li && (@login_info_component) && !@logged_in
			lic.request_logins
		end		
	end

end