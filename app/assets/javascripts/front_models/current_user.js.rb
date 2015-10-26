=begin
class Page < Model

  attributes :id, :title, :body, :assoc
  route "Find", get: "pages/:id"
  route "create", post: "pages"
  route "update", {put: "pages/:id"}, {defaults: [:id]}
  route "destroy", {delete: "pages/:id"}, {defaults: [:id]}
  
end
=end

require "front_models/user"

class CurrentUser < User

  def self.route(name, method_and_url, options)
    self.define_singleton_method(name.downcase) do | wilds = {}, req_options = {}|

      url = prepare_http_url_from(method_and_url, wilds)

      req_options = {payload: req_options}
      
      promise = Promise.new
      HTTP.__send__(method_and_url.keys[0], url, req_options) do |response|
        responses_on_get_current_user(response, promise) if name == "Get_current_user" 
        responses_on_logout(response, promise) if name == "Logout"
        responses_on_login(response, promise) if name == "Login"
      end
      promise
    end
  end

  def self.responses_on_get_current_user(response, promise)
    if response.ok?
      unless response.json[:user][:id]
        @logged_in = false
        promise.reject("guest")
      else
        x = Model.parse response.json
        @user_instance = Model.parse(response.json)      
        @logged_in = true
        promise.resolve(@user_instance)
      end
    else
      authorize!(response)
      @logged_in = false
      @user_instance = User.new
      "raise http error"
    end
  end

  def self.responses_on_logout(response, promise)
    if response.ok?
      @logged_in = false
      @user_instance = User.new
      promise.resolve(status: "ok") 
    else
      promise.reject(status: "error")
    end
  end

  def self.responses_on_login(response, promise)
    if response.ok?      
      @user_instance = Model.parse(response.json)
      @logged_in = true
      promise.resolve(status: "ok") 
    else
      promise.reject(statuts: "error")
    end
  end

  route "Get_current_user", post: "users/current_user"
  route "Logout", delete: "logout"
  route "Login", post: "login"

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
