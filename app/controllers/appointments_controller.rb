class AppointmentsController < ApplicationController

  def index
    @appointments =  Appointment.where("appointments.start_date >= ? AND appointments.end_date <= ?", from, to ).select(:start_date, :end_date, :doctor_id).order(:start_date)
    render json: @appointments.as_json
  end

end
