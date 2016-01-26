class AttributesPermitter::User::AppointmentScheduler::CreatePatient

  def initialize(params)
    @params = params.require(:user)  
  end

  def get_permitted
    @permitted_attributes = @params.permit(:email, profile_attributes: [:phone_number, :name])
    @permitted_attributes
  end

end