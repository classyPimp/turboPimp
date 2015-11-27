class MenuItem < Model
  attributes :id, :href, :link_text, :menu_items, :menu_items_attributes
  route "Index", get: "menu_items"
  route "update", {put: "menu_items/:id"}, {defaults: [:id]}
end    