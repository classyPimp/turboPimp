class Page < Model
  attributes :id, :body, :text, :user

  route "create", post: "pages"
  route "Index", get: "pages"
  route "destroy", {delete: "pages/:id"}, {defaults: [:id]}
  route "update", {put: "pages/:id"}, {defaults: [:id]}

  def validate_body(options = {})
    if body.length < 4
      add_error(:body, "too short!")
    end
  end
end