class AppointmentDetail < Model

  attributes :id, :appointment_id, :note, :extra_details

  def validate_extra_details
    if self.extra_details.length < 4
      add_error :extra_details, "please provide details of your visit"
    end
  end


end