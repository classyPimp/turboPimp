class AttributesPermitter::OfferedService::AdminCreate

  def initialize(params)
    @params = params.require(:offered_service)
  end

  def get_permitted
    @permitted_attributes = @params.
      permit(:title, :body, :m_title, :m_description, :m_keywords)
    @permitted_attributes
  end

end