class AttributesPermitter::User::Unregistered::Create

  def innitialize(params)
    @params = params.require(:user)  
  end

  def get_permitted
    @permitted_attributes = @params.permit(profile_attributes: [:phone, :name])
    @permitted_attributes
  end

end