require "controllers/base_controller"

class AppController < BaseController

	class << self
		attr_accessor :login_info_component
	end

  def self.logout_user
    CurrentUser.logout.then do |r|
      Components::App::Router.history.replaceState(nil, "/users/login")
    end.fail do |r|
      p "logout failed"
    end
  end

end