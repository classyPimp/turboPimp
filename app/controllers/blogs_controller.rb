class BlogsController < ApplicationController  
  
  def create

    @blog = Blog.new
    perms_for @blog
    auth! @perms

    @blog.update_attributes @perms.permitted_attributes
    current_user.blogs << @blog

    if @blog.save && current_user.save
      render json: @blog.as_json(@perms.serialize_on_success)
    else
      render json: @blog.as_json(@perms.serialize_on_error)
    end

  end

  def index  
    perms_for :Blog
    auth! @perms
    render json: @perms.model
  end
   
  def edit 

    perms_for :Blog

    auth! @perms

    render json: @perms.model

  end

  def update
    @blog = Blog.find(params[:id])
    perms_for @blog
    auth! @perms

    if @blog.update(@perms.permitted_attributes)
      render json: @blog.as_json(@perms.serialize_on_success)
    else
      render json: @blog.as_json(@perm.serialize_on_error)
    end
  end

  def destroy
    @blog = Blog.find(params[:id])
    perms_for @blog
    auth! @blog

    if @blog.destroy
      render  json: @blog.as_json
    end
  end
  
end
