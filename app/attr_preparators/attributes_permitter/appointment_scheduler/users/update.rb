class AttributesPermitter::AppointmentScheduler::Users::Update

  def initialize(params)
    @params = params.require(:user)  
  end

  def get_permitted
    @permitted_attributes = @params.permit(:email, profile_attributes: [:phone_number, :id, :bio, :name])
    @permitted_attributes
  end

end