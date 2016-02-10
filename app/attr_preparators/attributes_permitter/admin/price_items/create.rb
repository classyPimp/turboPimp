class AttributesPermitter::Admin::PriceItems::Create

  def initialize(params)
    @params = params.require(:price_item)
  end

  def get_permitted
    @permitted_attributes = @params.
      permit(:name, :price, :price_category_id)
    @permitted_attributes
  end

end