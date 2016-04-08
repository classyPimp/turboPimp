class Users::ProfilesController < ApplicationController

  def update_phone_number
    @profile = Profile.find(params[:id])
    
    perms_for @profile
    auth! @perms.update_phone_number

    cmpsr = ComposerFor::Profiles::UpdatePhoneNumber.new(@profile, params, self)

    cmpsr.when(:ok) do |profile|
      render json: profile.as_json(only: [:id, :phone_number])
    end

    cmpsr.when(:validation_fail) do |profile|
      render json: profile.as_json(only: [:id, :phone_number], methods: [:errors])
    end

    cmpsr.run

  end

end
