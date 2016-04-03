class PriceItem < Model

  attributes :id, :price, :name, :price_category_id

  has_one :offered_service

  route "Show", get: "price_items/:id"

  route "update", {put: "price_items/:id"}, {defaults: [:id]}

  route "create", post: "price_items"

  route "Index", get: "price_items"

  route "destroy", {delete: "price_items/:id"}, {defaults: [:id]} 

  route "Edit", {get: "price_items/:id/edit"}

  def validate_name
    unless name.length > 0
      add_error :name, 'name of the item should be provided'
    end
  end

  def validate_price
    unless price && price.length > 0
      add_error :price, 'price should be provided'
    end
  end


end
