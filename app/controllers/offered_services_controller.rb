class OfferedServicesController < ApplicationController

  def index
    
    perms_for OfferedService
    auth! @perms

    @offered_services = OfferedService.all

    render json: @offered_services.as_json(@perms.serialize_on_success)

  end

end
