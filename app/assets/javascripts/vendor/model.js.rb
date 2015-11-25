=begin
  NOTICE
  *****************OPAL JQUERY needs hack
  after this line
    settings, payload = @settings.to_n, @payload
  this should be inserted in opal_jquery opal gem 

    %x{
      if (typeof(#{payload}) === 'string' || #{@method == "get"}) {
        payload = #{@payload.to_n};
        #{settings}.data = $.param(payload);
      }
      else if (payload != nil) {
        settings.data = payload.$to_json();
        settings.contentType = 'application/json';
      }

      settings.url  = #@url;
      settings.type = #{@method.upcase};

      settings.success = function(data, status, xhr) {
        return #{ succeed `data`, `status`, `xhr` };
      };

      settings.error = function(xhr, status, error) {
        return #{ fail `xhr`, `status`, `error` };
      };

      $.ajax(settings);
    }

This dirty hack is needed for proper serialization of payload povided with ruby hash to query string on HTTP.get requests

If you're going to use zepto: zepto itself as well as opal-jquery need hack
Zepto should be defined on window.
If you get raised with something like "gvars[]$[]and stuff", in opal-jquery change from $$["Zepto"][:zepto][:Z] to `window.Zepto.zepto.Z`
don't know why it isn't working -- it should be!

********************************************************************

  HOW THIS WORKS
        MODELS
  your models should inherit from Model
  Model has parse class method tha traverses Hash || Array or stringified JSON and
  instantiates meeting models.
  Rails, should respond with json root eg {user: {id: 1}}
  When Model.parse if it will meet {model_name: {atr: "some", foo: "some"}} it will instantiate that #{model_name} and [:model_name] wll
  go to attribtes if in attributes there is model it will also be instantiated.
  if array of models given to model parse it will retun ModelCollection wich is basicaly the arry of models
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
  #@associations_list not yet implemented; think about it is there a reason to be?
  #they are handled as attribute now and we're not on backend, 
  #TODO: think about

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
      return ModelCollection.new(data)
    end
    parsed_data
  end
## THESE ARE NEEDED FOR PARSE CLASS METHOD
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
        begin
        data = HelperStuff.constantize(i.capitalize).new(value) if value.is_a? Hash
        rescue
          data[i] = self.objectify(value)
        end
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
## END THESE ARE NEEDED FOR PARSE CLASS METHOD

  def self.iterate_for_form(val, form_data, track = nil)
  #new formData() wrapped in Native shall be passed
  #val is the normalized attributes (containing no models) of a model
  #result is populated formData object to be passed to HTTP request with all the pure_attributes attached to it
  #this is  necessary for sending file though xhr only
  #TODO: depending if model has file defaultly make ajax data: formData returned from this method (can be done through validation)
  #TODO: fallback for ie < 10 and other shitty versions via iframe. But is there a true neccessity in such? 
    if val.is_a? Array
      val.each_with_index do |v, i| 
        track = track + "[#{i}]"
        iterate_for_form(v, form_data, track)  
      end
    elsif val.is_a? Hash
      val.each do |k, v|
        (track == nil) ? _track = k.to_s : _track = "#{track}[#{k}]"
        iterate_for_form(v, form_data, _track)
      end
    else   
      form_data.append track, val
    end
    form_data
  end


  #######INSTANCE

  #attr_accessor :attributes 

 
  def initialize(data = {})
    data = self.class.objectify(data, nil, true)
    @attributes = data
    @errors = {}
    init
    #again this init is needed for you to use intialize without super
    #looks neatier for me
  end

  def init
    #refer to #initialize for info
  end

  def attributes
    #in case you need attributes as a hash with models (not their pure attributes) 
    @attributes
  end

  def pure_attributes
    #for example you have a model {user: {id: 1, page: {page: {id: 2}}}}
    #parsed it ll be user.@attributes {id: 1, <Page instance>}
    #and you'll need it to pass to server, but @attributes will contain instantiated page not its attributes
    #this way it will return the pure hash as -> kind of reverse of Model.parse
    #BUG: CHANGES THE ACTUAL ATTRIBUTES! edit: changed a bit but behaviour needs examination
    x = {}
    attributes.each do |k,v| 
      #weird part of v.dup is needed when native objects (in single case I encounterd
      #the native file from input would otherwise niled)
      x[k] = normalize_attributes( (v.nil? ? v : (v.dup.nil? ? v : v.dup)) )
    end
    {self.class.name.downcase => x}
  end

  def normalize_attributes(attrs)
    #THIS METHOD IS ONLY NEEDED FOR #pure_attributes
    if attrs.is_a? Hash
      attrs.each do |k,v|
        if v.is_a? Model
          attrs[k] = v.attributes
        else 
          attrs[k] = normalize_attributes(v)  
        end
      end      
    elsif attrs.is_a? Array 
      attrs.map! do |val|
        normalize_attributes(val)
      end
    elsif attrs.is_a? Model
      attrs.pure_attributes
    else
      attrs
    end
  end

  def update_attributes(data)
    attrs = self.class.objectify(data, nil, true)
    @attributes.merge! attrs
    #TODO: implement deep merge
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

  def where(&block)
    #JUST BEGAN TO IMPLEMENT
    #wanth to have a search method which would traverse model or assciation deeply 
    #and will yield each model it finds and if the conditions in block will match for that model attrs
    #it'll grab that model to result association
    #why the block and not DSL? i thought of implementing sort of DSL for it, and almost wanted to make a separate class for that
    #but fucking with DSL is quite annoying and it'd be harder to maintain it later so what I want is
    #model_association.where do |a|
    #  a[:id] == 1 || a[:name].matches regex || a[:lenght] < 6 && a[:published] = "true"
    #end
    #and it's not a big deal )
    s = []
    attributes.each do |k, v|
      if v.is_a? Model
        s << v if yield(v.attributes)
        s = s + v.where {block.call}
      elsif v.is_a? Array
        v.each do |c|
          if c.is_a? Model
            s << c if yield(c.attributes) 
            s = s + c.where {block.call}
          end
        end
      end
    end
    s 
  end
=begin
  def self.associations(*args)
    #NOT YET IMPLEMENTED! it's here just beacuse it's here, and someday, some beatifull cloudy day i'll try do do
    #something with it!
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
  TODO: propbably shall be deleted beacuse association stuff can be done via routes, and no need in it on frontend
=end
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
#######MODEL WIDE RESPONSES TODO: add all REST methods and move to module
  
  def on_before_create(r)
    r.req_options = {payload: pure_attributes}
  end

  def responses_on_create(r)
    if r.response.ok?
      self.update_attributes(r.response.json[self.class.name.downcase])
      self.validate
      r.promise.resolve self
    end
  end

  def self.responses_on_index(r)
    if r.response.ok?
      r.promise.resolve self.parse(r.response.json)
    end
  end

  def responses_on_destroy(r)
    if r.response.ok?
      r.promise.resolve self          
    end
  end

  def self.responses_on_show(r)
    if r.response.ok?
      r.promise.resolve Model.parse(r.response.json)
    else
      r.promise.reject r.response.status_code
    end
  end

  def on_before_update(r)
    p "#{self} before on update"
    r.req_options = {payload: pure_attributes}
  end

  def responses_on_update(r)
    if r.response.ok?
      self.update_attributes(r.response.json[self.class.name.downcase])
      r.promise.resolve self
    end
  end




#                       __   __  _______  ___      ___   ______   _______  _______  ___   _______  __    _ 
#                      |  | |  ||   _   ||   |    |   | |      | |   _   ||       ||   | |       ||  |  | |
#                      |  |_|  ||  |_|  ||   |    |   | |  _    ||  |_|  ||_     _||   | |   _   ||   |_| |
#                      |       ||       ||   |    |   | | | |   ||       |  |   |  |   | |  | |  ||       |
#                      |       ||       ||   |___ |   | | |_|   ||       |  |   |  |   | |  |_|  ||  _    |
#                       |     | |   _   ||       ||   | |       ||   _   |  |   |  |   | |       || | |   |
#                        |___|  |__| |__||_______||___| |______| |__| |__|  |___|  |___| |_______||_|  |__|
                                                                
#that big letter are not for lulz, they are for easily navigate with that sublime all code view feature ;)
  #TODO: MOVE TO SEPARATE MODULE

  attr_accessor :errors
  #every model must have errors

  ############HAS FILE meths
  def has_file
    @file ||= false
  end

  def has_file=(value)
    @file = value
  end

  def serialize_attributes_as_form_data
    form_data = Native(`new FormData()`)
    self.class.iterate_for_form(self.pure_attributes, form_data)
  end

  def self.has_file
    false
    #for class routes methods todo: need some other wat
  end
  #this has file stuff is needed for cases when your model has collected file and wants to send it
  #to backend. The only way (for xhr of course) is to serialize it's attrs including file holding ones to formModel
  #that serialization is unnecessary job if model doesn't hold file, of course you could do everything manually but what for?
  #if your model has file holding attr, it will run validate_file_holing attribute, and that validate method has to set has_file to true
  #in validate method reset_errors will also assign has_file a false value
  #HTTP handler will check for that shit in initialize and will call model to serialize it's attrs to form and 
  #will assign data: that_serialized_form.
  #this serialize_attributes_for_form_data can be in use elsewhere if you'll needed. 

  def has_errors?
    !@errors.empty? #|| !(self.attributes[:errors] ||= {}).empty?
  end

  def reset_errors
    #It will set errors to empty hash
    # if  your view depends on errors (to show them or not)
    #youll need to reset them before each validation
    #TODO: recursion is not deep in here, not as deep as Grey's throat, but it needs to be!
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
    self.reset_errors
    self.has_file = false
    #for this method refer to itself; needed for serializing to automatic serialization to formData
    @attributes.each do |k, v|
      unless options[:only].empty?
        next unless options[:only].include? k
      end
      if v.is_a? Array
        v.each do |m|  
          if m.is_a? Model
            m.validate
            if m.has_errors?
              @errors[:nested_errors] = true       
            end
          end
        end
      else
        self.send("validate_#{k}") if self.respond_to? "validate_#{k}"
        #p (self.respond_to? "validate_#{k}") ? "has validation method #{k}" : "doesn't have validation method #{k}"
        @errors ||= {}
        @errors.merge!(self.attributes[:errors] ||= {})
        self.attributes[:errors] = {}
        #in case errors teturned from server, but no validation rules for it on fronts  
      end
    end 
  end

  def add_error(attr_name, error)
    #attr_name model : Model <attr_name>, error : String
    #this method is called in validate_#{attr_name} method if your
    #attr has errors and you need to add it, but youre free to not use it
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
    #TODO: shoould move it elsewere?
    #needed purely for Model.parse method
    string.split('::').inject(Object) {|o,c| o.const_get c}
  end

end

class ModelCollection
  #you will get it if will pass array of models to Model.parse 
  include Enumerable
  attr_accessor :data
  def initialize(data = [])
    data.map! do |val|
      Model.parse(val)
    end
    @data = data
    init
  end

  def init
    
  end

  def where(&block)
    s = []
    @data.each do |v|
      if v.is_a? Model
        s << v if yield(v) #previously was v.attributes; changed beacause sometimes yo'll need to check on their methods not only attributes
        s = s + v.where {block.call}
      end
    end
    s 
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

  def empty?
    @data.empty?
  end

  def to_s
    "#{self.class}: [#{@data}]"
  end

  def remove(obj)
    @data = @data.delete_if do |val|
      val == obj
    end
    self
  end
end


=begin
       ______    _______  _______  __   __  _______  _______  _______    __   __  _______  __    _  ______   ___      _______  ______   
      |    _ |  |       ||       ||  | |  ||       ||       ||       |  |  | |  ||   _   ||  |  | ||      | |   |    |       ||    _ |  
      |   | ||  |    ___||   _   ||  | |  ||    ___||  _____||_     _|  |  |_|  ||  |_|  ||   |_| ||  _    ||   |    |    ___||   | ||  
      |   |_||_ |   |___ |  | |  ||  |_|  ||   |___ | |_____   |   |    |       ||       ||       || | |   ||   |    |   |___ |   |_||_ 
      |    __  ||    ___||  |_|  ||       ||    ___||_____  |  |   |    |       ||       ||  _    || |_|   ||   |___ |    ___||    __  |
      |   |  | ||   |___ |      | |       ||   |___  _____| |  |   |    |   _   ||   _   || | |   ||       ||       ||   |___ |   |  | |
      |___|  |_||_______||____||_||_______||_______||_______|  |___|    |__| |__||__| |__||_|  |__||______| |_______||_______||___|  |_|
=end

class RequestHandler
  #handles your HTTP requests!!! Really! this get's started from your Model.route method, look there
  
  attr_accessor :caller, :promise, :name, :response, :req_options

  def initialize(caller, name, method_and_url, options, wilds, req_options)
  
    @caller = caller
    #the model that called either instance or class
    @name = name
    #name of the route
    @options = options
    @wilds = wilds
    #handy little :foo s
    #as well as options holder like 
    #yield_response: true => will override default response handlers
    #component: component's self => will make RW comonent available
    #TODO: should wilds be renamed now? they're more options now than wilds as back then when they were young and silly little args
    @component = wilds[:component]
    #if you need to pass component to Http (e.g. turn on spinner before request, swith off after)
    #or any other sort of that
    #pass component in first arg like
    #user.some_route({component: self})
    #and youll have access to it in automatic response handlers (or anywhere in requesthandler)
     @should_yield_response = wilds[:yield_response]
    #handy if you need unprocessed response
    #e.g. simply pass user.some_route({yield_response: true}, {}) {|response| unprocessed response}
    @skip_before_handler = wilds[:skip_before_handler]
    #if you need to override defualts before request is made
    #pass this option to wild as {skip_before_handler: true}
    #else it's false by defaul
    @url = prepare_http_url_for(method_and_url)
    #makes youre route get: "url/:foo",
    #passes default for wilds, or attaches one from wilds option

    @http_method = method_and_url.keys[0]
    @req_options ||= {}
    extra_params = {}
    #TODO: WATCH the behaviour
    if req_options[:extra_params] != nil
      extra_params = req_options[:extra_params]
    end
    @req_options.merge! extra_params
    if req_options[:data]
    #ve done it for these reasons:
    #if passed as payload it will be to_json,
    #depending on what you're passing it may throw some shit at you because it'll be to_n'ed
    #the main reason was to be able to pass files via formData
      @req_options = req_options
    elsif req_options[:payload]
      @req_options = req_options
    elsif @caller.has_file
      p "gon serialize to form data #{@caller.pure_attributes}"
      #this skip before is needed to override default's on model class which result in payload: something; not data
      @skip_before_handler = true
      @caller.update_attributes extra_params
      @req_options[:data] = @caller.serialize_attributes_as_form_data
      @req_options[:processData] = false
      @req_options[:contentType] = false
      #For info on this method refer to validation part of model
    else
      @req_options = {payload: @req_options}
    end
    #TODO: NEED TO THROUGHLY PLAN AND STANDARTIZE THE OPTIONS THAT CAN BE PASSED FOR REQUEST!
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
      #TODO: raise if route is defined with wild but no wild was resolved defaultly or not was given through wild arg
    end
    url.unshift('api')
    #adds prefix to url as apiv1/url
    #TODO: move to as constant of Model 
    "/#{url.join('/')}"
    #returns full url
  end

  def send_request
    @promise = Promise.new
    defaults_before_request
    #the super defaults app wide.
    #TODO: need option to override
    if @caller.respond_to?("on_before_#{@name.downcase}") && !@skip_before_handler
      @caller.send "on_before_#{@name.downcase}", self
      #JUST BEGAN TO IMPLEMENT AND DIDN't plan yet how to do!
      #the idea is to provide default prepare for ajax data (payload) on
      # rest actions e.g. save, update, destroy, etc/
      #so you wont need to user.destroy({}, payload: user.pure_attributes),
      #and simply user.destroy and that's it!
      #and be like responses_on_route_name
      #EDIT: it kinda works now as of nov 17 2015, but needs reviewing
    end
    HTTP.__send__(@http_method, @url, @req_options) do |response|
      @response = response 
      if @should_yield_response
        yield_response
        #handy if you need unprocessed response
        #e.g. simply pass user.some_route({yield_response: true}, {}) {|response| unprocessed response}
      elsif @caller.respond_to? "responses_on_#{@name.downcase}"
        @caller.send "responses_on_#{@name.downcase}", self
        #this will call the default actions on response if they are defined
        #the convention is that model shall implemenet responses_on_<route_name> method
        #else defaults will run
      else
        default_response
      end
      defaults_on_response
      #SUPER DEFAULTS ON RESPONSE
      #TODO: make option to override
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
  
end
