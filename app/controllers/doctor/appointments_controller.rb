class Doctor::AppointmentsController < ApplicationController

  def create
    @appointment = Appointment.new
    perms_for @appointment
    auth! @perms
    @appointment.update_attributes @perms.permitted_attributes
    if @appointment.save  
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
    @appointments = Appointment.includes(:appointment_detail, patient_id_user_id_: [:profile]).where("start_date >= ?", from).where("end_date <= ?", to)
    render json: @appointments.as_json(include: [{appointment_detail: {root: true}}, {patient: {root: true, include: {profile: {root: true}}}}])
  end

end
