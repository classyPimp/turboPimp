require "opal"
require "promise"
class Model

  
  @@authorizible = true
  @@prefix = 'api'

  def self.authorize!(response)
    if @@authorizible && response.status_code == "401"
      self.class.emit_anuthorized(response.json)
    end
  end

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

  def self.route(*args)
    args.each do |arg|
      if arg.is_a? Hash
        arg
      end
    end
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
    #update attributes on instantiated object
    #simply replaces @attributes.
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

  def self.route(name, method_and_url, options)
    if name == "Find"
      self.define_singleton_method(name.downcase) do | wilds = {}, req_options = {}|

        url = prepare_http_url_from(method_and_url, wilds)

        req_options = {payload: req_options}
        
        promise = Promise.new
        HTTP.__send__(method_and_url.keys[0], url, req_options) do |response|
          if response.ok?
            promise.resolve Model.parse(response.json)
          else
            authorize!(response)
            "raise http error"
          end
        end
        promise
      end
    else
      #route :save, post: "pages/:id", defaults: [:id]
      self.define_method(name) do |wilds = {}, req_options = {}|
        
        should_yield_response = wilds[:yield_response]

        url = self.class.prepare_http_url_from(method_and_url, wilds)
        
        req_options = {self.class.name.downcase => req_options}
        req_options = {payload: req_options}
        
        promise = Promise.new
        HTTP.__send__(method_and_url.keys[0], url, req_options) do |response|        
          if response.ok?
            if name == "destroy"
              _id = self.id
              promise.resolve status: "ok", destroyed: _id              
            else
              if should_yield_response
                promise.resolve response.json
              else
                self.update_attributes response.json[self.class.name.downcase]
                promise.resolve self
              end
            end
          else
            self.class.authorize!(response.json)
            self.errors << "response error"
            promise.reject self
          end
        end
        promise
      end
    end
  end

  def self.prepare_http_url_from(method_and_url, wilds)
  #prepares passed method_and_url from self.route
  url = method_and_url[method_and_url.keys[0]].split('/')
  url.map! do |part|
    if part[0] == ":"
      if wilds[part[1..-1]]
        wilds[part[1..-1]]
      end
    else
      part
    end
  end
  #url[-1] = "#{url[-1]}.json"
  #adds prefix to url as apiv1/url
  url.unshift(@@prefix)
  "/#{url.join('/')}"

  #returns full url
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












