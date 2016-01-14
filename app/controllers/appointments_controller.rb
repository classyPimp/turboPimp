class AppointmentsController < ApplicationController

  def index
    @appointments =  Appointment.where("appointments.start_date >= ? AND appointments.end_date <= ?", from, to ).select(:start_date, :end_date, :doctor_id).order(:start_date)
    render json: @appointments.as_json
  end

  def create

    @appointment = Appointment.new 

    perms_for @appointment
    auth! @perms
    
    byebug
    if @current_user

      @appointment.patient_id = @current_user.id
      cmpsr = ComposerFor::Appointment::Proposal::CreateByRegisteredUser.new(@appointment)

    else
      
      cmpsr = ComposerFor::Appointment::Proposal::CreateByUnregisteredUser.new(@appointment, @perms.arbitrary[:unregistered_user_permitted_attributes])

    end

    cmpsr.when(:ok) do |appointment|
      render json: @appointment.as_json(@perms.serialize_on_success)
    end

    cmpsr.when(:fail) do |appointment|
      render json: @appointment.as_json(@perms.serialize_on_error)
    end

    cmpsr.when(:fail_unregistered_user_validation) do |user|
      render json: user.as_json(only: [], methods: [:errors])
    end

    cmpsr.run

  end

end
