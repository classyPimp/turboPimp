class PriceCategoriesController < ApplicationController

  def index
    perms_for PriceCategory
    auth! @perms

    @price_categories = PriceCategory.all.includes(:price_items)

    render json: @price_categories.as_json(@perms.serialize_on_success)
  end

end
