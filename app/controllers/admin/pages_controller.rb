class Admin::PagesController < ApplicationController

  def index  
    perms_for Page
    auth! @perms.admin_index
    render json: @perms.model
  end 

end
