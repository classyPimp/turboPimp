class Profile < Model
  attributes :id, :bio, :name, :user_id

  def validate_name
    if name.length < 2
      add_error :name, "name can't be blank"
    end
  end
end