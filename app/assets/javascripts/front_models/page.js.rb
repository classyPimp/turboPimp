class Page < Model
  attributes :id, :body, :title, :user,
             :m_title, :m_description, :m_keywords

  route "create", post: "pages"
  route "Index", get: "pages"
  route "destroy", {delete: "pages/:id"}, {defaults: [:id]}
  route "update", {put: "pages/:id"}, {defaults: [:id]}
  route "Show", {get: "pages/:id"}

  def validate_body(options = {})
    if body.length < 4
      add_error(:body, "too short!")
    end
  end
end