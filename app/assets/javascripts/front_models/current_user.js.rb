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
    if name == "Get_current_user"
      self.define_singleton_method(name.downcase) do | wilds = {}, req_options = {}|

        url = prepare_http_url_from(method_and_url, wilds)

        req_options = {payload: req_options}
        
        promise = Promise.new
        HTTP.__send__(method_and_url.keys[0], url, req_options) do |response|
          if response.ok?
            if response.json[:user][:id] == nil
              promise.reject("guest")
            else
              @user_instance = Model.parse(response.json)            
              @logged_in = true
              promise.resolve(@user_instance)
            end
          else
            authorize!(response)
            @logged_in = false
            @user_instance = nil
            "raise http error"
          end
        end
        promise
      end
    end
  end

  route "Get_current_user", get: "users/current_user"

  @user_instance ||= User.new
  @logged_in = false

  class << self
    attr_accessor :user_instance
    attr_accessor :is_logged_in?
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
