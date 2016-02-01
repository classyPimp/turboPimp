class FakerController < ApplicationController

	def home
    if current_user
      @current_user = current_user.as_json(only: [:id, :email, :registered], roles: current_user.general_roles_as_json)
    else
      @current_user = nil
    end
  end
    			

  def console
   raise "hello there!"   
  end

	def test
    x = {options: ["foo", "bar", "baz", "cux"]}
		render json: x
	end

  def restricted_asset
    if current_user
      send_file Rails.root + "app/assets/javascripts/foo.js.rb", type: "application/javascript"
    else
      head 403
    end
  end
end
