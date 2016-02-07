class Blog < Model

  attributes :id, :body, :title, :user_id,
             :m_title, :m_description, :m_keywords, :slug, :published, :published_at
  has_one :user

  route "create", post: "blogs"
  route "Index", get: "blogs"
  route "destroy", {delete: "blogs/:id"}, {defaults: [:id]}
  route "update", {put: "blogs/:id"}, {defaults: [:id]}
  route "Show", {get: "blogs/:id"}
  route "Edit", {get: "blogs/:id/edit"}

  route "Last_ten", {get: "blogs/last_ten"}

  route "Index_for_group_list", {get: "blogs/index_for_group_list"}

  route "toggle_published", {put: "blogs/toggle_published"}

  def self.responses_on_index_for_group_list(r)
    self.responses_on_index(r)
  end

  def self.responses_on_last_ten(r)
    if r.response.ok?
      collection = Model.parse(r.response.json)
      r.promise.resolve collection
    end
  end

  def on_before_toggle_published(r)
    r.req_options = {payload: {blog: {id: self.id}}} 
  end

  def responses_on_toggle_published(r)
    if r.response.ok?
      r.promise.resolve Model.parse(r.response.json)
    end
  end

  def validate_body
    self.body = self.body.strip
    if body.length < 10
      add_error(:body, "body is too short")
    end
  end

end