class AppointmentScheduler::AppointmentsController < ApplicationController

  def index
    perms_for Appointment
    auth! @perms

    
  end

end
