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

  def edit
    @appointment = Appointment.joins(:appointment_detail, patient: [:profile]).select("appointments.*, profiles.user_id AS sj_patient2user1sj_profile1user_id, profiles.name AS sj_patient2user1sj_profile1name, appointment_details.note AS sj_appointment_detail1note, appointment_details.id AS sj_appointment_detail1id").find(params[:id])
    perms_for @appointment
    auth! @perms

    render json: @appointment.as_json
  end

  def index
    perms_for Appointment
    auth! @perms
    from = Date.parse(params[:from])
    to = Date.parse(params[:to])

    @appointments =  Appointment.joins(:appointment_detail, patient: [:profile]).where("appointments.start_date >= ? AND appointments.end_date <= ?", from, to ).select("appointments.*, profiles.name AS sj_patient2user1sj_profile1name, appointment_details.note AS sj_appointment_detail1note")
    render json: @appointments.as_json
  end

  def show
    @appointment = Appointment.joins(:appointment_detail, patient: [:profile]).select("appointments.*, profiles.user_id AS sj_patient2user1sj_profile1user_id, profiles.name AS sj_patient2user1sj_profile1name, appointment_details.note AS sj_appointment_detail1note, appointment_details.id AS sj_appointment_detail1id").find(params[:id])
    perms_for @appointment
    auth! @perms

    render json: @appointment.as_json
  end

  def update
    @appointment = Appointment.find(params[:id])
    perms_for @appointment
    auth! @perms
    if @appointment.update(@perms.permitted_attributes) && (@appointment = Appointment.joins(:appointment_detail, patient: [:profile]).select("appointments.*, profiles.user_id AS sj_patient2user1sj_profile1user_id, profiles.name AS sj_patient2user1sj_profile1name, appointment_details.note AS sj_appointment_detail1note, appointment_details.id AS sj_appointment_detail1id").find(params[:id]))
      render json: @appointment.as_json
    else
      render json: @page.as_json(@perm.serialize_on_error)
    end
  end

  def destroy
    @appointment = Appointment.find(params[:id])
    perms_for @appointment
    auth! @perms
    if @appointment.destroy
      render json: @appointment
    end
  end

end
