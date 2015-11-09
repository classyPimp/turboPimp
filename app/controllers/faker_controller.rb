class FakerController < ApplicationController

	def home
				
	end

	def test
		render plain: params
	end
end
