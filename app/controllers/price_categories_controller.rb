class PriceCategoriesController < ApplicationController

  def index
    perms_for PriceCategory
    auth! @perms

    @price_categories = PriceCategory.all.includes(price_items: [:si_offered_service1id_slug])

    render json: @price_categories.as_json(@perms.serialize_on_success)
  end

end
