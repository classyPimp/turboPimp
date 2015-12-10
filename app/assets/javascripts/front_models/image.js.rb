class Image < Model
	attributes :id, :file, :url, :user_id, :alt, :description, :search_query

	route "create", post: "images"
  route "Index", get: "images"
  route "destroy", {delete: "images/:id"}, {defaults: [:id]}
  route "update", {put: "images/:id"}, {defaults: [:id]}

  def validate_file
  	self.has_file = true
  end

  def validate_alt
    if alt.length < 2
      add_error :alt, "provide alt"
    end
  end
end
