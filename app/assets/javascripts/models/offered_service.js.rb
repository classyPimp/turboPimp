class OfferedService < Model

  attributes :id, :body, :title, :user_id,
             :m_title, :m_description, :m_keywords, :slug, :published, :published_at
  has_one :user
  has_one :avatar
  has_many :price_items

  route "create", post: "offered_services"
  route "Index", get: "offered_services"
  route "destroy", {delete: "offered_services/:id"}, {defaults: [:id]}
  route "update", {put: "offered_services/:id"}, {defaults: [:id]}
  route "Show", {get: "offered_services/:id"}
  route "Edit", {get: "offered_services/:id/edit"}

end