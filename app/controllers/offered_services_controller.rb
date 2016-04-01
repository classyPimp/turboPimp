class OfferedServicesController < ApplicationController

  def index
    
    perms_for OfferedService
    auth! @perms

    @offered_services = OfferedService.includes(:si_price_items1id_name_price, :avatar).all

    render json: @offered_services.as_json(@perms.serialize_on_success)

  end

  def show
    
    @offered_service = OfferedService.friendly.find(params[:id])

    render json: @offered_service.as_json({include: [{avatar: {root: true}}, {si_price_items1id_name_price: {root: true}}]})

  end

end
