class AttributesPermitter::Admin::PriceItems::Update

  def initialize(attributes)
    @attributes = attributes
  end

  def get_permitted
    @permitted_attributes = @attributes.permit(:name, :price)
    @permitted_attributes
  end

end