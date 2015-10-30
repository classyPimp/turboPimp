require "front_models/user"

class CurrentUser < User

  def self.responses_on_get_current_user(request_handler)
    r = request_handler
    if r.response.ok?
      unless r.response.json[:user][:id]
        @logged_in = false
        r.promise.reject("guest")
      else
        x = Model.parse r.response.json
        @user_instance = Model.parse(r.response.json)      
        @logged_in = true
        r.promise.resolve(@user_instance)
      end
    else
      @logged_in = false
      @user_instance = User.new
      "raise http error"
    end
  end

  def self.responses_on_logout(request_handler)
    r = request_handler
    if r.response.ok?
      @logged_in = false
      @user_instance = User.new
      r.promise.resolve(status: "ok") 
    else
      r.promise.reject(status: "error")
    end
  end

  def self.responses_on_login(request_handler)
    r = request_handler
    if r.response.ok?      
      @user_instance = Model.parse(r.response.json)
      @logged_in = true
      r.promise.resolve(status: "ok") 
    else
      r.promise.reject(statuts: "error")
    end
  end

  route "Get_current_user", post: "users/current_user"
  route "Logout", delete: "logout"
  route "Login", post: "login"
  route "Request_password_reset"

  @user_instance ||= User.new
  @logged_in = false

  class << self
    attr_accessor :user_instance
    attr_accessor :logged_in
  end

  def self.get
    if @user_instance.id != nil       
      @user_instance
    else
      @logged_in = false
      self.get_current_user
    end
  end

  def self.ping
    self.get_current_user
  end

end
