class AppointmentScheduler::AppointmentsController < ApplicationController

  def index
    perms_for Appointment
    auth! @perms.appointment_scheduler_index

    @appointments = Appointment.unscheduled_with_doctors_and_proposal_infos
    
    render json: @appointments.as_json(@perms.serialize_on_success)

  end

end
