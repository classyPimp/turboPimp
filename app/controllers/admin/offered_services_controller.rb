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
      render json: _offered_service.as_json(methods: [:errors])
    end

    cmpsr.run

  end



end
