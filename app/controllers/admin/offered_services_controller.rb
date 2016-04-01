class Admin::OfferedServicesController < ApplicationController

  def create
    byebug
    perms_for OfferedService
    auth! @perms.admin_create
    @offered_service = OfferedService.new
    cmpsr = ComposerFor::OfferedService::AdminCreate.new(@offered_service, params, self)

    cmpsr.when(:ok) do |_offered_service|
      render json: _offered_service.as_json
    end

    cmpsr.when(:validation_fail) do |_offered_service|
      render json: _offered_service.as_json(methods: [:errors], include: [{avatar: {methods: [:errors]}}])
    end

    cmpsr.run

  end


  def edit

    @offered_service = OfferedService.find(params[:id])
    perms_for @offered_service
    auth! @perms.admin_edit
    render json: @offered_service.as_json(@perms.serialize_on_success)

  end

  def update
    
    @offered_service = OfferedService.find(params[:id])
    
    perms_for @offered_service
    auth! @perms.admin_update

    cmpsr = ComposerFor::OfferedService::AdminUpdate.new(@offered_service, params, self)

    cmpsr.when(:ok) do |offered_service|
      render json: offered_service.as_json(@perms.serialize_on_success)
    end

    cmpsr.when(:validation_fail) do |offered_service|
      byebug
      render json: offered_service.as_json(@perms.serialize_on_error)
    end

    cmpsr.run

  end

  def destroy
     
    @offered_service = OfferedService.find(params[:id])

    perms_for @offered_service
    auth! @perms.admin_destroy

    @offered_service.destroy

    render json: @offered_service.as_json({only: [:id]})

  end


end
