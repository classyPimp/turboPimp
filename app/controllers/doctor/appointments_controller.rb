class Doctor::AppointmentsController < ApplicationController

  def create
    @appointment = Appointment.new
    perms_for @appointment
    auth! @perms
    @appointment.update_attributes @perms.permitted_attributes
    if @appointment.save
      @appointment = Appointment.joins(:appointment_detail, patient: [:profile]).select("appointments.*, profiles.name AS sj_patient2user1sj_profile1name, appointment_details.note AS sj_appointment_detail1note").find(@appointment.id)  
      render json: @appointment.as_json(@perms.serialize_on_success)  
    else
      render json: @appointment.as_json(@perms.serialize_on_error)
    end    
  end

  def index
    perms_for Appointment
    auth! @perms
    from = Date.parse(params[:from])
    to = Date.parse(params[:to])

    @appointments =  Appointment.joins(:appointment_detail, patient: [:profile]).select("appointments.*, profiles.name AS sj_patient2user1sj_profile1name, appointment_details.note AS sj_appointment_detail1note")
    render json: @appointments.as_json
  end

end
