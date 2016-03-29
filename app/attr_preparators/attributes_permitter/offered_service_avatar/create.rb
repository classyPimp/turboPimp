class AttributesPermitter::OfferedServiceAvatar::Create

  def initialize(params)
    @params = params.require(:offered_service_avatar)
  end

  def get_permitted
    @permitted_attributes = @params.
      permit(:avatar)
    @permitted_attributes
  end

end