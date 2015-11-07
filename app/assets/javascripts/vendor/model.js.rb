=begin
  HOW THIS WORKS
        MODELS
  your models should inherit from Model
  Model has parse class method tha traverses Hash || Array or stringified JSON and
  instantiates meeting models.
  Rails, should respond with json root eg {user: {id: 1}}
  When Model.parse if it will meet {model_name: {atr: "some", foo: "some"}} it will instantiate that #{model_name} and [:model_name] wll
  go to attribtes if in attributes there is model it will also be instantiated.
  if array of models given to model parse it will retun ModelAssociation wich is basicaly the arry of models
  attributes are stored in @attributes wich are passed on init
  each model has .attributes runtime called method that defines getter setter methods on @attributes
  to update attributes call update_attributes({hash}) which will merge it to attributes TODO implement deep_merge on ::Hash

        HTTP REQUESTS
  in your model you define routes as:
  route :find => will define method #find
  for class method routes route shall be capitalized
  route :Find => will define method .find
  second arg is url
  route :find, "/users"
  so model.find will make request to /users
  also you can pass wilds to url
  route :find, "users/:id"
  this works as expected
  to add the payload to request you should pass hash as 2nd arg
  .find {}, {user: {email: user.email}} => will result in payload: {users: {email: user.email}}
  if you had wild in route definition, you have to supply it in first arg as
  .find {id: 1}, {payload : Hash}
  you can pass {defaults: [:your wild, :your 2nd wild]} in route definition option
  route :find, "users/:id", {defaults: [:id]} =>
  so if you will not supply wild when calling wild will be taken from return value of Model || model.__send__ #{wild}
  
  if you need to handle response in .then .fail customly, supply {yield_response: true} as first arg; as
  .find {yield_response: true, id: 2}.then {|response| do somethind with esponse}.fail {|response| do spmething else} 

  when you call defined route request is handled by RequestHandler class

  RequestHandler has everything needed (passed from invoking model) as: response , urld and etc Model || model from which RequestHadler was
  initialized; you can call it by request_handler.caller

  If you call Model model route from component, or any other object you can pass components self to RequestHandler in first arg (wilds)
  as render; User.find({component: self}, {payload: {foo: "bar"}}); then the component will be available as instance var @component

  to define custom scenarios of response automatic handling you should define
  responses_on_#{your route name} methods that accepts RequestHandler instance
  that instance has accessors on everything you need e.g. .response .promise and etc
  example:
      def self.responses_on_find(request_handler)
        if request_handler.response.ok?
          request_handler.promise.resolve Model.parse(request_handler.response.json)
        else
          "raise http error"
        end
      end

  to provide default actions on response there is RequestHandler#defaults_on_response where you put code that should run
  for any response

  You can monkeypatch Model in Helpers, (you mostly will need it for defaults modethods); now they are
  #defaults_before_request (as expected)
  #defaults_on_response (just add if @response.ok else and will run defaultly)
  
  sorry for my french
=end

require "opal"
require "promise"
class Model

  @attributes_list
  #@associations_list not yet implemented

  class << self
    attr_accessor :attributes_list
    attr_accessor :associations_list
  end

  def self.parse(data)
    if data.is_a? String
      data = JSON.parse(data)
    end
    parsed_data = objectify data
    if parsed_data.is_a? Array
      return ModelAssociation.new(data)
    end
    parsed_data
  end

  def self.objectify(data, class_name = "Model", objectify_model = nil)
    
    data = objectify_array(data)

    data = objectify_single_model(data)

    if data.is_a? Hash
      data = objectify_from_model(data)
    end

    data

  end

  def self.objectify_array(data)
    if data.is_a? Array
      data = data.each_with_index do |v, i|     
        data[i] = self.objectify(v)
      end
    end
    data
  end

  def self.objectify_single_model(data)
    if (data.is_a? Hash) && (data.size == 1) 
      data.each_with_index do |(i, value), index|
        #TODO raise on constant missing, rescue with parse on value, and passing k as symbol to model 
        data = HelperStuff.constantize(i = i.capitalize).new(value) if value.is_a? Hash
      end
    end
    data
  end

  def self.objectify_from_model(data)
    data.each_with_index do |(k, v), index|
      if (v.is_a? Hash) || (v.is_a? Array)
        data[k] = objectify(v)
      end
    end
    data
  end

  #######INSTANCE

  attr_accessor :attributes 
  attr_accessor :errors

  def initialize(data = {})
    data = self.class.objectify(data, nil, true)
    @attributes = data
    @errors = {}
    init
  end

  def has_errors?
    !@errors.empty?
  end

  def init
    
  end

  def update_attributes(data)
    attrs = self.class.objectify(data, nil, true)
    @attributes.merge! attrs
  end

  def self.attributes(*args)
    @attributes_list = args
    args.each do |arg|
      self.define_method arg do | |
        @attributes[arg]
      end

      self.define_method "#{arg}=" do |val|
        @attributes[arg] = val
      end
    end
  end

  def self.associations(*args)
    @associations_list = args
    args.each do |arg|
      self.define_method arg do | |
        @associations_list[arg]
      end

      self.define_method "#{arg}=" do |val|
        @associations_list[arg] = val
      end
    end
  end

  def self.route(name, method_and_url, options ={})
    if name[0] == name.capitalize[0]
      self.define_singleton_method(name.downcase) do | wilds = {}, req_options = {}|
        RequestHandler.new(self, name, method_and_url, options, wilds, req_options).promise
      end
    else
      #route :save, post: "pages/:id", defaults: [:id]
      self.define_method(name) do |wilds = {}, req_options = {}|
        RequestHandler.new(self, name, method_and_url, options, wilds, req_options).promise
      end  
    end
  end

  def self.responses_on_find(request_handler)
    p "#{self}.reponses on find"
    if request_handler.response.ok?
      request_handler.promise.resolve Model.parse(request_handler.response.json)
    else
      "raise http error"
    end
  end

  def responses_on_destroy(request_handler)
    p "#{self}.responses_on_destroy"
    if request_handler.response.ok?
      _id = self.id
      request_handler.promise.resolve status: "ok", destroyed: _id              
    else
      (self.errors[:request] ||= []) << "connection_error"
       request_handler.promise.reject self
    end
  end

  #++++++++++++VALIDATION++++++++++++++++
  #TODO shall it be moved to plugins?

  def has_errors?
    !@errors.empty?
  end

  def validation_rules
    #in this method you define validation rules for your attributes
    #IMPORTANT the validation methods' names should be  validate_#{attribute_name}
    #TODO: consider remakin the #validate to validatin_rules[:attr].call if it's not nil  
    #your model should implement this method like:
    # attr_name: ->(options = {}){validate_attr_name}
    #THIS IS NOT NEEDED NOW THE VALIDATIONS ARE SIMPLY __SEND__ to model if respond_to
    #it's left if
    {
      
    }
  end

  def reset_errors
    #WRITE DOCS
    attributes.each do |k,v|
      if v.is_a? Model
        v.reset_errors
      end
      if v.is_a? Array
        v.each do |c|
          c.reset_errors if c.is_a? Model
        end
      end
    end
    @errors = {}
  end

  def validate(options = {only: []})
    @attributes.each do |k, v|
      unless options[:only].empty?
        next unless options[:only].include? k
      end
      if v.is_a? Array
        v.each do |m|  
          if m.is_a? Model
            m.validate
            p m.errors
            if m.has_errors?
              @errors[:thereareerrors] = true       
            end
          end
        end
      else
        self.send("validate_#{k}") if self.respond_to? "validate_#{k}"
        #p (self.respond_to? "validate_#{k}") ? "has validation method #{k}" : "doesn't has validation method #{k}"
        #refactor to validation_rules[:attr].call(options) if 
      end
    end 
  end

  def add_error(attr_name, error)
    #attr_name model : Model <attr_name>, error : String
    #this method is called in validate_#{attr_name} method if your
    #attr has errors
    #refer to important! notice  
    (@errors[attr_name] ||= []) << error
  end

  ####
  #IMPORTANT!
  #your model should implement validate_attr_name for the attr you need to validate
  #this method should recieve optional option : Hash arg
  #and it should result in either add_error(:attr_name, "bad error")
  #or doing it manually, example
  #def validate_name
  # if name.length < 8
  #   add_error :name, "too short"
  # end
  #end
  #for convinience errors are assumed to have structure
  #repeating it's attributes hash
  #model.attributes => {name: "foo"}
  #model.validate
  #model.errors => {name: ["too short"]}
  #model.attributes => {name: "foo"}

  #-----------------END VALIDATION============

end

class HelperStuff

  def self.constantize(string)
    string.split('::').inject(Object) {|o,c| o.const_get c}
  end

end

class ModelAssociation
  
  include Enumerable
  attr_accessor :data
  def initialize(data = [])
      @data = data
  end

  def <<(val)
      @data << val
  end

  def each(&block)
      @data.each(&block)
  end

  def [](value)
    @data[value]
  end

  def to_s
    "#{self.class}: [#{@data}]"
  end

  def remove(obj)
    @data = @data.reject do |val|
      val == obj
    end
  end
end

class RequestHandler
  
  attr_accessor :caller, :promise, :name, :response

  def initialize(caller, name, method_and_url, options, wilds, req_options)
    @caller = caller
    @name = name
    @options = options
    @wilds = wilds
    @component = wilds[:component]
    @should_yield_response = wilds[:yield_response]
    @url = prepare_http_url_for(method_and_url)
    @http_method = method_and_url.keys[0]
    @req_options = {payload: req_options}
    send_request
  end

  def prepare_http_url_for(method_and_url)
    url = method_and_url[method_and_url.keys[0]].split('/')
    url.map! do |part|
      if part[0] == ":"
        if @wilds[part[1..-1]]
          @wilds[part[1..-1]]
        elsif  (@options[:defaults].find_index(part[1..-1]) if @options[:defaults].is_a?(Array))
          @caller.send part[1..-1]
        end
      else
        part
      end
    end
    #url[-1] = "#{url[-1]}.json"
    #adds prefix to url as apiv1/url
    url.unshift('api')
    "/#{url.join('/')}"
    #returns full url
  end

  def send_request
    @promise = Promise.new
    defaults_before_request
    HTTP.__send__(@http_method, @url, @req_options) do |response|
      begin
      @response = response
      defaults_on_response 
      if @should_yield_response
        yield_response
      elsif @caller.respond_to? "responses_on_#{@name.downcase}"
        @caller.send "responses_on_#{@name.downcase}", self
      else
        default_response
      end
      rescue
        @promise.reject(errors: ["connection error"])
      end
    end
    @promise
  end

  def yield_response(response, promise)
    if @response.ok?
      @promise.resolve @response.json
    else
      @promise.reject @response.json
    end
  end

  def default_response(response, promise)
    if @response.ok?
      @promise.resolve @response.json
    else
      @promise.reject @response.json
    end
  end

  def defaults_before_request
    
  end

  def defaults_on_response

  end
  
end
