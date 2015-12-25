require "models/user"

class CurrentUser < User

  attributes :remember_me

  extend Helpers::PubSubBus  
  allowed_channels :on_user_logged_in, :on_user_logout

  route "Get_current_user", post: "users/current_user"
  route "Logout", delete: "logout"
  route "Login", post: "login"
  route "Request_password_reset", post: "password_resets"
  route "Update_new_password", put: "password_resets/:id"

  @user_instance ||= User.new(roles: [{role: {name: "guest"}}])
  @logged_in = false

  class << self
    attr_accessor :user_instance
    attr_accessor :logged_in
  end

  def self.logged_in=(val)
    if val
      self.pub_to(:on_user_logged_in, @user_instance)
    else
      self.pub_to(:on_user_logout, @user_instance)
    end
    @logged_in = val
  end
  
  def self.responses_on_get_current_user(r)
    if r.response.ok?
      unless r.response.json[:user][:id]
        @logged_in = false
        r.promise.reject(User.new)
      else

        @user_instance = Model.parse(r.response.json)      
          
        p @user_instance.pure_attributes

        login_success
        
        r.promise.resolve(@user_instance)
      end
    else
      @logged_in = false
      @user_instance = User.new
    end
  end

  def self.responses_on_logout(r)
    if r.response.ok?
      @logged_in = false
      @user_instance = User.new

      self.pub_to(:on_user_logout, @user_instance)

      r.promise.resolve(@user_instance) 
    else
      r.promise.reject(status: "error")
    end
  end

  def self.responses_on_login(r)
    if r.response.ok?      
      @user_instance = Model.parse(r.response.json)
      p @user_instance
      login_success
      r.promise.resolve(r.response.json) 
    else
      r.promise.reject(statuts: "error")
    end
  end

  def self.responses_on_request_password_reset(r)
    if r.response.ok?
      @user_instance = Model.parse(r.response.json)
      login_success
      r.promise.resolve(status: "ok") 
    else
      r.promise.reject(errors: r.response.json[:errors])
    end       
  end

  def self.responses_on_update_new_password(r)
    if r.response.ok?      
      @user_instance = Model.parse(r.response.json)

      login_success

      r.promise.resolve(status: "ok") 
    else
      r.promise.reject(statuts: "error")
    end
  end 

  def self.login_success
    if @user_instance.is_a? User
      @logged_in = true 
      self.pub_to(:on_user_logged_in, @user_instance)
    end
  end

end

