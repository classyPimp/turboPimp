class Blogger::BlogsController < ApplicationController

  def last_ten
    perms_for :Blog

    auth! @perms.blogger_last_ten

    render json: @perms.model  
  end

  def index  
    perms_for :Blog
    auth! @perms.blogger_index
    render json: @perms.model
  end

  def toggle_published
    @blog = Blog.find(params[:blog][:id])
    perms_for @blog
    auth! @perms.blogger_toggle_published

    @blog.published = !@blog.published

    if @blog.save
      render json: @blog.as_json
    end
  end

  
end
