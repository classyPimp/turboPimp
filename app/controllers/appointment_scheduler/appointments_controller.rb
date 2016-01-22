class AppointmentScheduler::AppointmentsController < ApplicationController

  def proposal_index

    perms_for Appointment
    auth! @perms.appointment_scheduler_proposal_index

    @appointments = Appointment.unscheduled_with_doctors_and_proposal_infos
    
    render json: @appointments.as_json(@perms.serialize_on_success)

  end

  def index
    
    perms_for Appointment
    auth! @perms.appointment_scheduler_index

    User.arbitrary[:from] = params[:from]
    User.arbitrary[:to] = params[:to]

    #@user_ids_to_query = Appointment.where('scheduled = ? AND start_date >= ? AND end_date <= ?', true, params[:from], params[:to]).pluck('DISTINCT doctor_id')
    @user_ids_to_query = params[:doctor_ids]
    @users_with_appointments = User.where(id: @user_ids_to_query).includes(:si_appointments1as_doctor_all, :si_profile1id_name).select(:id)

    render json: @users_with_appointments.as_json(@perms.serialize_on_success)

    User.arbitrary.delete(:from)
    User.arbitrary.delete(:to)

  end

  def schedule_from_proposal
    
    perms_for Appointment
    auth! @perms.appointment_scheduler_schedule_from_proposal

    render plain: params and return    

  end

end
