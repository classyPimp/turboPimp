class PagesController < ApplicationController
		
	def create
		@page = Page.new(create_params)
		if @page.save
			render json: @page.as_json(only: [:id, :text, :body])
		else
			render json: {page: {errors: @page.errors}}
		end

	end

	def create_params
		params.require(:page).permit(:text, :body)
	end
end
