class FakerController < ApplicationController

	def home
    @current_user = current_user.as_json(only: [:id, :email])				
	end

  def console
    raise "Hello there!"
  end

	def test
    x = params.require(:user).permit(:email, avatar_attributes: [:file], profile_attributes: [:bio])
		render plain: x
	end

  def restricted_asset
    if current_user
      send_file Rails.root + "app/assets/javascripts/foo.js.rb", type: "application/javascript"
    else
      head 403
    end
  end
end
