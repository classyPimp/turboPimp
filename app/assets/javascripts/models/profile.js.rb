class Profile < Model
  attributes :id, :bio, :name, :user_id, :phone_number
  
  route "update_phone_number", {put: "profiles/:id/update_phone_number"}, {defaults: [:id]}

  def on_before_update_phone_number(r)
    self.on_before_update(r)    
  end

  def responses_on_update_phone_number(r)
    self.responses_on_update(r)
  end

  def validate_name
    if name.length < 2
      add_error :name, "name can't be blank"
    end
  end
end