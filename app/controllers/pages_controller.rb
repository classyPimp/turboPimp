class PagesController < ApplicationController
	
	before_action :require_logged_in_user, only: [:create, :update]	

	def create
		@page = Page.new(create_params)
		if @page.save
			render json: @page.as_json(only: [:id, :title, :body])
		else
			render json: {page: {errors: @page.errors}}
		end
	end

	def index
		@pages = Page.all.paginate(page: params[:page], per_page: 2)
		@pages = @pages << {pagination: {current_page: @pages.current_page, total_entries: @pages.total_entries, total_pages: @pages.total_pages,
												offset: @pages.offset}} 
		render json: @pages
	end

	def update
		@page = Page.find(params[:id])
		@page.body, @page.title  = update_params[:body], update_params[:title]
		if @page.save
			render json: @page
		else
			render json: {errors: @page.errors}
		end
	end

  def show
    @page = Page.friendly.find(params[:id])
    render json: @page.as_json(only: [:id, :title, :body, :m_title, :m_description, :m_keywords])
  end

	def destroy
		@page = Page.find params[:id]
		@page.destroy
		render json: @page
	end

	def create_params
		params.require(:page).permit(:title, :body, :m_title, :m_keywords, :m_description)
	end

	def update_params
		params.require(:page).permit(:title, :body, :m_title, :m_keywords, :m_description)
	end
end
