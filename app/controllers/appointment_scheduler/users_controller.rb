class AppointmentScheduler::UsersController < ApplicationController

  def create
    
    perms_for User
    auth! @perms.appointment_scheduler_create

    permitted_attributes = AttributesPermitter::User::AppointmentScheduler::CreatePatient.new(params).get_permitted

    cmpsr = ComposerFor::AppointmentScheduler::Users::CreatePatient.new(permitted_attributes)

    cmpsr.when(:ok) do |user|
      render json: user.as_json(@perms.serialize_on_success)
    end    

    cmpsr.when(:fail) do |user|
      render json: user.as_json(@perms.serialize_on_error)
    end

    cmpsr.run

  end

end
