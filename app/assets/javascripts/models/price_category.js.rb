class PriceCategory < Model

  attributes :name, :id

  has_many :price_items

  route "Show", get: "price_categories/:id"

  route "update", {put: "price_categories/:id"}, {defaults: [:id]}

  route "create", post: "price_categories"

  route "Index", get: "price_categories"

  route "destroy", {delete: "price_categories/:id"}, {defaults: [:id]} 

  route "Edit", {get: "price_categories/:id/edit"}

  def validate_name
    unless name == nil || name.length > 0
      add_error :name, 'name of the category should be provided'
    end
  end

end