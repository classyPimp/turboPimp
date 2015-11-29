class MenuItem < Model
  attributes :id, :href, :link_text
  route "Index", get: "menu_items"
  route "update", {put: "menu_items/:id"}, {defaults: [:id]}

  has_many :menu_items
  accepts_nested_attributes_for :menu_items
end
