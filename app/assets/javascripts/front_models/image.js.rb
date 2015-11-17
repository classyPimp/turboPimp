class Image < Model
	attributes :id, :file, :url, :user_id

	route "create", post: "images"
  route "Index", get: "images"
  route "destroy", {delete: "images/:id"}, {defaults: [:id]}
  route "update", {put: "images/:id"}, {defaults: [:id]}

  def validate_file
  	self.has_file = true
  end
end
