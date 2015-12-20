class Role < Model
  
  attributes :name, :id, :user_id

  route :Index, get: "roles"

end