require "vendor/model"

class User < Model

  attributes :id, :email, :password, :password_confirmation

  route "sign_up", post: "users"

end