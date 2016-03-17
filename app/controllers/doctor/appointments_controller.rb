class Doctor::AppointmentsController < ApplicationController

  def create
    @appointment = Appointment.new
    perms_for @appointment
    auth! @perms.doctor_create
    @appointment.attributes = @perms.permitted_attributes
  
    cmpsr = ComposerFor::Appointment::Doctor::Create.new(@perms.permitted_attributes)
    
    cmpsr.when(:ok) do |appointment|
      @appointment = appointment
      @appointment = Appointment.joins(:appointment_detail, patient: [:profile]).select("appointments.*, profiles.name AS sj_patient2user1sj_profile1name, appointment_details.note AS sj_appointment_detail1note").find(@appointment.id)  
      render json: @appointment.as_json(@perms.serialize_on_success)
    end
    
    cmpsr.when(:fail) do |appointment|
      appointment[:appointment]
      render json: @appointment.as_json(@perms.serialize_on_error)
    end    
    
    cmpsr.run
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
    doctor_ids = params[:doctor_ids]

    @appointments =  Appointment.joins(:appointment_detail, patient: [:profile]).where("appointments.start_date >= ? AND appointments.end_date <= ? AND appointments.doctor_id IN (?)", from, to, doctor_ids ).select("appointments.*, profiles.name AS sj_patient2user1sj_profile1name, users.id AS sj_patient2user1id, appointment_details.note AS sj_appointment_detail1note")
    #@appointment = Appointment.josin(:appointment_detail, patient: [:profile]).where("appointments.start_date >= ? AND appointments.end_date <= ? AND appointments.doctor_id IN (?)", from, to, doctor_ids )
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
    auth! @perms.doctor_update

    cmpsr = ComposerFor::Appointment::Doctor::Update.new(@appointment, @perms.permitted_attributes)
    
    cmpsr.when(:ok) do |appointment|
      @appointment = Appointment.joins(:appointment_detail, patient: [:profile]).select("appointments.*, profiles.user_id AS sj_patient2user1sj_profile1user_id, profiles.name AS sj_patient2user1sj_profile1name, appointment_details.note AS sj_appointment_detail1note, appointment_details.id AS sj_appointment_detail1id").find(params[:id])
      render json: @appointment
    end

    cmpsr.when(:fail) do |appointment|
      render json appointment.as_json(@perms.serialize_on_error)
    end

    cmpsr.run

  end

  def destroy

    @appointment = Appointment.find(params[:id])
    perms_for @appointment
    auth! @perms

    cmpsr = ComposerFor::Appointment::Doctor::Destroy.new(@appointment)
    
    cmpsr.when(:ok) do |appointment|
      render json: appointment
    end

    cmpsr.run

  end

end
