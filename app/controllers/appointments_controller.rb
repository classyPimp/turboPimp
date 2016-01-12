class AppointmentsController < ApplicationController

  def index
    @appointments =  Appointment.where("appointments.start_date >= ? AND appointments.end_date <= ?", from, to ).select(:start_date, :end_date, :doctor_id).order(:start_date)
    render json: @appointments.as_json
  end

  def create
    @appointment = Appointment.new
    perms_for @appointment
    auth! @appointment

    @appointment.attributes = @perms.permitted_attributes

    if @current_user
      if @appointment.save && current_user.save
        render json: @appointment.as_json(@perms.serialize_on_success)
      else
        render json: @appointment.as_json(@perms.serialize_on_error)
      end
    else
      if User.create_with_proposal(@perms.arbitrary[:unregistered_user_permitted_attributes], @appointment)
        render json: @appointment.as_json(@perms.)
      end
    end
  end

end
