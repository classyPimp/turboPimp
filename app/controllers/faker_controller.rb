class FakerController < ApplicationController

	def home
				
	end

  def console
    raise "HELLO THERE!"
  end

	def test
    x = params.require(:user).permit(:email, avatar_attributes: [:file], profile_attributes: [:bio])
		render plain: x
	end
end
