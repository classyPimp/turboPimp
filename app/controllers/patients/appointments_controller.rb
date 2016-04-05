class Patients::AppointmentsController < ApplicationController

  def index
    
    perms_for Appointment
    auth! @perms.patients_index

    User.arbitrary[:from] = params[:from]
    User.arbitrary[:to] = params[:to]
    User.arbitrary[:patient_id] = current_user.id 

    @users_with_appointments = User.joins(:appointments_as_doctor)
                                   .where("appointments.start_date >= ? AND appointments.end_date < ? AND appointments.patient_id = ?", 
                                      User.arbitrary[:from], User.arbitrary[:to],
                                      current_user.id
                                    )
                                   .select(:id).distinct
    
    render json: @users_with_appointments.as_json(@perms.serialize_on_success)

  end

end
