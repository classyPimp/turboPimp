class AttributesPermitter::Admin::PriceCategories::Create

  def initialize(params)
    @params = params.require(:price_category)
  end

  def get_permitted
    @permitted_attributes = @params.
      permit(:name)
    @permitted_attributes
  end
  
end