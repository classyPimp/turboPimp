class PagesController < ApplicationController
	
	before_action :require_logged_in_user, only: [:create, :update]	

	def create
		@page = Page.new
    perms_for @page
    auth! @perms

    @page.attributes = @perms.permitted_attributes
    current_user.pages << @page

    if @page.save && current_user.save
      render json: @page.as_json(@perms.serialize_on_success)
    else
      render json: @page.as_json(@perms.serialize_on_error)
    end
	end

	def edit
    @page = Page.find(params[:id])
    perms_for @page
    auth! @perms
    render json: @page.as_json
  end

	def index
    perms_for Page
    auth! @perms
    render json: @perms.model
	end

	def update
		@page = Page.find(params[:id])
    perms_for @page
    auth! @perms
    if @page.update(@perms.permitted_attributes)
      render json: @page.as_json(@perms.serialize_on_success)
    else
      render json: @page.as_json(@perm.serialize_on_error)
    end
	end

  def show
    @page = Page.friendly.find(params[:id])
    render json: @page.as_json(only: [:id, :title, :body, :m_title, :m_description, :m_keywords])
  end

	def destroy
		@page = Page.find params[:id]
		perms_for @page
		auth! @perms
		if @page.destroy
			render json: @page
		end
	end

end
