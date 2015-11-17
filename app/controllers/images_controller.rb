class ImagesController < ApplicationController

	before_action :require_logged_in_user	

	def create
		@image = Image.new(create_params)
		if @image.save
			render json: @image.as_json(only: [:id], methods: [:url])
		else
			render json: {image: {errors: @image.errors}}
		end
	end

	def index

		@images = Image.all.paginate(page: params[:page], per_page: 2)
		render json: @images.as_json(only: [:id], methods: [:url]) << 
												{pagination: {current_page: @images.current_page, total_entries: @images.total_entries, total_pages: @images.total_pages,
												offset: @images.offset}} 
	end

	def update
		#below is was just copied from pages_controller if update meth is needed should rewrite
		@image = Image.find(params[:id])
		if @image.save
			render json: @image
		else
			render json: {errors: @image.errors}
		end
	end

	def destroy
		@image = Image.find params[:id]
		@image.destroy
		render json: @image.as_json(only: [:id])
	end

	def create_params
		params.require(:image).permit(:file)
	end

	def update_params
		params.require(:image).permit(:file)
	end

end
