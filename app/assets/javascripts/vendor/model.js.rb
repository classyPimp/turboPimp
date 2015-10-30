require "opal"
require "promise"
class Model
 
  def emit_anuthorized(response)
    #EXAMPLE AppController.launch_anauthorized_precedures(repsonse)
  end

  @attributes_list
  @associations_list

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
    @errors = []
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
      self.errors << "response error"
      request_handler.promise.reject self
    end
  end

 

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
    HTTP.__send__(@http_method, @url, @req_options) do |response|
      p "#{self}.send_request"
      @response = response
      authorize! @response
      if @should_yield_response
        yield_response
      elsif @caller.respond_to? "responses_on_#{@name.downcase}"
        @caller.send "responses_on_#{@name.downcase}", self
      else
        default_response
      end
    end
    @promise
  end

  def yield_response(response, promise)
    p "#{self} yield response"
    if @response.ok?
      @promise.resolve @response.json
    else
      @promise.reject @response.json
    end
  end

  def default_response(response, promise)
    "p #{self}.default_response"
    if @response.ok?
      @promise.resolve @response.json
    else
      @promise.reject @response.json
    end
  end

  def defaults_if_ok 

  end

  def defaults_if_not_ok
    authorize!(@response)
  end

  def authorize!
    #LOGIC ON 401 RESPONSE
  end
end
