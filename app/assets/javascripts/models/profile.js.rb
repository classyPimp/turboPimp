class Profile < Model
  attributes :id, :bio, :name, :user_id, :phone_number

  def validate_name
    if name.length < 2
      add_error :name, "name can't be blank"
    end
  end
end