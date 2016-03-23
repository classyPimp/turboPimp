class AttributesPermitter::Admin::PriceCategories::Update

  def initialize(attributes)
    @attributes = attributes
  end
  
  def get_permitted
    @permitted_attributes = @attributes.permit(:name)
    @permitted_attributes
  end

end