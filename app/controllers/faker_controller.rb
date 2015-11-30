class FakerController < ApplicationController

	def home
				
	end

  def console
    raise "HELLO THERE!"
  end

	def test
		render plain: params
	end
end
