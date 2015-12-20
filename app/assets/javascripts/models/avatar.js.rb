class Avatar < Model
  attributes :id, :file, :url, :user_id

   def validate_file
    self.has_file = true
  end
end  