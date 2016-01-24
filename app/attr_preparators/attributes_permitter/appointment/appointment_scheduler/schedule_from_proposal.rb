class AttributesPermitter::Appointment::AppointmentScheduler::ScheduleFromProposal

  def initialize(params)
    @params = params.require(:appointment)
  end

  def get_permitted
    @permitted_attributes = @params.
      permit(:start_date, :end_date, :patient_id, :doctor_id)
    @permitted_attributes
  end

end