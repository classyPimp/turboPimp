# TurboPimp:

##### Greetings! And thanks for visiting!

I don't have a CS degree and I'm not even close related to IT field, and my coding (as a pure hobby from absolute beginner I could't even "hello world!") began on previous year's (July 2014 (Ruby since Dec 2014)) vacation, and teaching myself on spare time after day job.  
Please don't laugh on code quality, and if you see something wrong please tell me where and teach me if you can.   
This is the first thing I've done on my own.  

### Preface
The library itself is not bundled to it's own gem yet, beacuse I'm writing it in a way of building real life like app featurese, meeting problems, ammend the lib to solve them.
You can easilly extract it manually.  
The lib itself is not in 0.0.0.1 state, but not super stable, and it's more for the purpose of proof of concept/demo/feedback.

### Short description
Chaotic soup of React, ReactRouter, wrapped in Opal with generous dash of model.

### the purpose
maybe you'll find it usefull and use yourself, or just try it find what's wrong and teach me something.

### Installation
```
git clone
bundle
configure postgress DB
rake db:migrate
rails s
navigate to /
signup one user
navigate to /console
User.first.add_role :admin
Use demo

```

To extract to your app for now copy javascripts folder and delete everything in components, models.  
basically you need only: react.js, vendor/react_wrapper, vendor/model and that's it, copy to your app and require to pipeline.

# THE MODEL
your models should inherit from `Model`.

Model has `.parse` class method that traverses Hash || Array or stringified JSON and
  instantiates models if it meets them.
  
**Rails, should respond with json root true (can be enabled in config) eg {user: {id: 1}} not the default {id: 1}** (this can be done in Rails config or manually on serialization to JSON)

 When `Model.parse` is called, if it will meet `{model_name: {atr: "some", foo: "some"}}` it will instantiate that `#{model_name}` and and its attributes wll
  go to `@attributes` of `#{model_name}`. If attribute holds another model it will also be instantiated.
  
  > example:
 ```
  x = Model.parse({user: {id: 1, friend: {user: {id: 2}}}})
  p x
  => <User_instance>
  p x.attributes
  =>{id: 1, friend: <User_instance>}
  p x.pure_attributes
  => {user: {id: 1, friend: {user: {id: 2}}}}
# if array of models given to model parse it will retun ModelCollection wich 
# is basicaly the array of models
  x = Model.parse([{user: {id: 1}}, {user: {id: 2}}])
  p x.data
  [<User_instance>, <User_instance>]
```

  **attributes are stored in `@attributes` accessor which is a simple hash.**

  each model has `.attributes` runtime called class method that defines getter setter methods which will basically get/set values from @attributes
```  
  class User
    attributes :id, :name
  end
  x = User.new(id: 1, name: "Joe", nickname: "Schmoe")
  p x.attributes
  => {id: 1, name: "Joe", nickname: "Schmoe"}
  p x.name
  => "Joe"
  x.name = "Foo"
  p x.nickname
  => method missing
  p x.attributes[:nickname]
  => "Schmoe"
  x.attributes[:nickname] = "Bar"
  p x.attributes[:nickname]
  => "Bar"
  p x.pure_attributes
  => {user: {id: 1, name: "Foo", nickname: "Bar"}}
```

  to update attributes call `update_attributes({hash})` which will merge it to `@attributes`

  `@attributes` is a hash containing what was given to `Model.parse`
  but when model was parsed, as mentionedf above it will instantiate all meeting instances (if they're defined). E.g.
```
  x = Model.parse({user: {id: 1, friend: {user: {id: 2}}}})
  p x.attributes
  #=>{id: 1, friend: <User_instance>}
  p x.friend.id
  #=> 2
  p x.friend.attributes
  #=> {id: 2}
        ***if you need "pure" attributes structure, simply call #pure_attributes***
  p x.pure_attributes
  #=> {user: {id: 1, friend: {user: {id: 2}}}}
```
You can instantiate a model with attributes .via new as well

## HTTP REQUESTS/backend communication for models
  **ALL route calls are managed by RequestHandler class which configures everything on each route call**  
**ALL route calls return Opal Promise so you have to handle responses in .then .fail.**
**ALL route calls urls will be prefixed with "api/", this can be configured in model**
```
  User.show(id: 1).then do |response|
    p response.json
    {user: {id: 1, name: "F"}}
    user = Model.parse(x)
    p user
    <User:instance>
    p user.attributes
    {id: 1, name: "F"}
    user.name = "Foo"
    user.save.then do |response|
      p response.status_code
      => 200
    end
  end.fail do |r|
    raise "failed"
  end
```
### map of backend communication routes
  you define the map of HTTP calls via class .route method like this which shall be called in class body definition:
```
  class User
    
    route :find => will define method instance method #find 
    route :Find => (capitalized) will define method class method .find 
  
  end  
```
  second arg is http method and url pair
```
  class User
    route :Show, get: "/users"
  end
  User.show
  => makes HTTP.get "/api/users" request to server
```
  also you can pass wilds to url:
  `route :Show, post: "users/:id"`  
this works as you expect it to. But then you'll have to provide the `:id` if calling that route like so:
  `Model.show({id: 1})
  => makes HTTP.post "/api/users/1" request to server`

  you can pass `{defaults: [:your_wild, :your_2nd_wild]}` in route definition option and it will be resolved automatically
  if you have corresponding method defined (e.g. called attributes :id):
```
  class User
    attributes :id, :name
    route :update, put: "users/:id", {defaults: [:id]}
  end
  user = User.show(id: 10)
  user.name = "Joe"
  user.update
  => makes HTTP.put "/api//users/10" request to server
```
  *Behind the scenes it follows: if you will not supply wild when calling route, wild will be taken from return value of <Model>.__send__ #{wild}*
### adding payload to request
  When making request you can add some payload to it.
  There are two ways:

###    Manual payload configuration
  To add the payload to request you should pass hash containing what you want to send, as 2nd arg. Usually that'll be #pure_attributes, but it can be anything 
```
  user = User.new
  user.name = "Joe"
  user.save({}, payload: user.pure_attributes)
  => makes HTTP.post request to "/api/users", with payload: {user: {name: "Joe"}}
```
###    Automatic payload configuration
  Simply define the following method either class or instance, corresponding your defined routes.  
 Such method shall have one argument, before the request will be made `RequestHandler` instance for that request is passed to that method
  you can access requst options by using `request_handler`'s accessor `req_options`, basically treat it like the second arg for route call
```
  attributes :id
  route "update", put: "users/:id", defaults: [:id]

  def on_before_update(r) ## #{route_name} 
    r.req_options = {payload: self.attributes}
    #same as manual =>  user.update({}, {payload: user.pure_attributes})
  end
```
  now you can simply do it like so:

```
  User.show(id: 1).then do |response|
    user = User.parse(response.json)
    user.name = "Foo"
    user = User.update.then do |response|
      #=> makes put request to "/api/users/1", with payload {user: {id: 1, name: "Foo"}}
      user = User.parse response.json
    end
  end
```

###    automatic handling on response
  Your responses can also be automatically resolved via this way:  
  define class or instance methods with this naming rules
  `responses_on_#{route_name}`

```
  route "Show", get: "users/:id"
  route "update", put: "users/:id", defaults: [:id]

  def self.responses_on_show(request_handler)
    if request_handler.response.ok?
      request_handler.promise.resolve Model.parse(request_handler.response.json)
    else
      "raise http error"
    end
  end

  def  responses_on_update(r)
    if r.response.ok?
      r.promise.resolve Model.parse(r.response.json)
    else
      #handle error
    end
  end

  def on_before_update(r) ## #{route_name} 
    r.req_options = {payload: self.attributes}
    #same as manual =>  user.update({}, {payload: user.pure_attributes})
  end
```

Now it'll get pretty simple, after you've done auto payload conf and reponse handling you'll be able to:

```
  User.show(id: 1).then do |user|
    #=> get request to "users/1"
    p user.attributes
    #=> {user: {id: 1, name: "joe"}}
    user.name = "Schmoe"
    user.update.then do |user|
      #=> put request to "users/1", payload: {user: {id: 1, name: "Schmoe"}}
      p user.attributes
      #=> {user: {id: 1, name: "Schmoe"}}
      #and e.g. set_state user: user
    end
  end
```


#### RequestHandler
  As it was mentioned all route requests are managed by `RequestHandler` class, which'll spawn object for each requesy being done/ 
  `RequestHandler` has everything needed (passed from invoking model) as: `response` , `url` and etc Model || model from which RequestHadler was
  initialized; you can call it by `request_handler.caller`

  If you call Model model route from component, or any other object you can pass anything to RequestHandler in first arg (wilds).

```
  User.find({component: self}, {payload: {foo: "bar"}});
```
then the component will be available as instance accessor `@component`

for example:
```
  #in some component
  user.update({component: self})

  #in User
  def on_before_update(r)
    r.component.spinner.on
  end

  def responses_on_update(r)
    r.component.spinner.off
  end
```


#### Defaults for all requests by any model

  You can monkeypatch Model in Helpers, (you mostly will need it for defaults before and after response handling modethods); they are  
  
  `defaults_before_request` (as expected)  
  `defaults_on_response` (just add if @response.ok else and will run defaultly)

#### Defaults for rest actions

  Default `on_before_#{rest_action_name}` and `responses_on_#{rest_action_name}` for standard REST actions are predefined in model
  They are:
  create  
  before: will payload: pure_attributes  
  after: on 200 instantiate model and yield it to then  

  Index  
  afer: on 200 instantiate collection and yield it to then

  destroy  
  after: on 200 will yield model self to then

  Show  
  after: on 200 will instatiate model and yield it to then

  update  
  before: will payload: pure_attributes  
  after: on 200 instantiate model and yield it to then

#### accepts_nested_attributes_for

to use Rail's accepts_nested_attributes_for capabilities
```
  has_one :friend
  has_many :dogs
  
  accepts_nested_attributes_for :friend, :dogs
  
  user = User.new
  p user.pure_attributes
  #=> {user: {friend: {}, dogs: []}}
  dog = Dog.new(nick: "Doge")
  user.dogs << dog
  friend = User.new(name: "bar")
  user.friend = friend
  p user.attributes
  #=> {dogs: [<Dog_instance>], friend: <User_instance>}
  p user.pure_attributes
  #=> {user: {friend_attributes: {name: "bar"}, dogs_attributes: [{nick: "Doge"}]}}
```

###  serializing to JS FormData

  need sending payload as form data (maybe you need to send JS File via route)
```  
  user.update({}, serialize_as_form: true)
  => will payload valid FormData object to HTTP request no matter how many stuff is nested
```

### searching in model or in collection

if your model holds in one of it's attributes (e.g. has_many dogs) you can search them via #where method
```
  x = user.where do |foo|
    foo[:attributes][:nick] == "Doge"
  end
  p x => <Dog_instance>
  
```
**same way you can search ModelCollection**

#### ModelCollection
simple array of model instances, iteratable and treated as array, everything stored in @data accessor, which is an array
```
col = Model.parse([{user: {name: "joe the dog"}}, {user: {name: "Luke", dogs: [{dog: {nick: "mr. woofer"}}]}}])
p Model.data
#=>[<User_instance>, <User_instance>]
p col[0].dogs[0].nick
#=>"mr. woofer"
dogs = col.where do |dog|
  dog.is_a? Dog
end
p dogs
#=> [<Dog_instance>]
```

###  MODEL VALIDATIONS

Your model should implement `validate_#{attr_name}` for the attr you need or want to validate  
This method should recieve optional `option: Hash arg`
and it should result in `add_error(:attr_name, "bad error")` if conditions not met  
or doing it manually, example
```
  def validate_name(opt)
   if name.length < 8
     add_error :name, "too short"
   end
  end
```
**for convinience errors are assumed to have structure**
repeating it's attributes hash
```
model.attributes => {name: "foo"}
model.validate
model.errors => {name: ["too short"]}
model.attributes => {name: "foo"}
```

if you don't have corresponding attributes defined those validation won't run
```
User.new
user.validate
user.has_errors?
=> false
user.name = "f"
user.has_errors?
=> true
```
**validate will validate any nested model as well with their own validation rules**

If your server responsds with errors in json e.g. user was validated on rails and responded with `{user: {errors: {name: ["too short"]}}}`
when Model.parse 'ed those errors will present
```
User.new
user.name = "f"
user.validate(only: ["email"]) # skipping :name validation
user.has_errors? #=> false
user.create.then do |user|
  user.validate
  user.has_errors? 
  #=> true
end
```

  to reset errors call `#reset_errors`

  example in react component
```  
class FormSample < RW
  expose

  include Plugins::Formable

  def get_initial_state
    form_model: User.new
  end
  
  render
    t(:div, {},
      input(Forms::Input, state.form_model, :name),
      t(:button, onClick: ->{handle_inputs})
    )
  end

  def  handle_inputs
    collect_inputs #given by plugin will collect all inputs, form_model.reset_errors (to clear errors from previous validate) and call validate
    #or your own way of collecting inputs and then
    #state.form_model.validate
    unless state.form_model.has_errors?
      state.model.create.then do |user|
        user.validate
        unless user.has_errors? #or add validate in responses_on_create and just use in .then has_errors?
          App::Router.replaceState({}, "/users/#{user.id}")
        end
      end
    else
      set_state form_model: state.form_model
      #formable plugin will render errors for each input if attr on model has corresponding error
    end 
  end
end
```

##### skipping validations

  validate can accept options like `only: [:name]` will validate only those and etc.

#### validation and files and `has_file` for automatic serialization to FormData

  if you have attribute that supposed to recive JS File from file input
  in order to send it via XHR (route).
  youe model should `has_file = true`
  it can be done via
```
  attributes :avatar

  def  validate_avatar
    if avatar
      self.has_file = true
    end
  end
```

  than validate your model and next time you'll call route payload will be serialized to form data/

  Model has more stuff, will document them later/ And it can be used solely as model layer for any app or another JS library/

  SNEAK PEAK ON HOW MODEL CAN BE USED IN RW COMPONENT
```
  class User < Model

    attributes :id, :email, :password, :password_confirmation

    route "sign_up", post: "users"
    route "Show", get: "users/:id"
    route "create", post: "users"
    route "update", put: "users/:id", defaults: [:id]
   
    has_one :profile, :avatar
    has_many :roles
    accepts_nested_attributes_for :profile, :avatar

    def validate_email(options={})
      unless email.match /^[-a-z0-9~!$%^&*_=+}{\'?]+(\.[-a-z0-9~!$%^&*_=+}{\'?]+)*@([a-z0-9_][-a-z0-9_]*(\.[-a-z0-9_]+)*\.(aero|arpa|biz|com|coop|edu|gov|info|int|mil|museum|name|net|org|pro|travel|mobi|[a-z][a-z])|([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}))(:[0-9]{1,5})?$/i
        add_error :email, "you should provide a valid email"
      end
    end

    def has_role?(role)
      roles.each do |_role|
        return true if role.include? _role.name 
      end
    end

    def validate_password
      if password.length < 6
        add_error :password, "password is too short"
      end
      if password != password_confirmation
        add_error :password_confirmation, "confirmation does not match"
      end
    end
  end
  
  module Users
  class New < RW
    expose

    include Plugins::Formable <= makes forms extra EASY

    include Plugins::DependsOnCurrentUser #<= will load the permision on component_did_mount automatically
    set_roles_to_fetch :admin #<= needed for above

    def get_initial_state
      {
        form_model: User.new(profile: {profile: {}}, avatar: {avatar: {}}) 
      }
    end

    def component_will_mount
      AppController.sub_to(:general_channel, self)
    end

    def  general_channel(msg)
      if msg = "reset"
        force_update
      end
    end

    def  component_will_unmount
      AppController.unsub_from(:generall_channel, self)
    end

    def render
      t(:div, {},
        spinner, #THAt shit'll spin when model requests are done and stops when recieved automatically
        t(:div, {className: "form"},
          input(Forms::Input, state.form_model.profile, :name), 
          input(Forms::Input, state.form_model, :email, {type: "text"}),
          input(Forms::Input, state.form_model, :password, {type: "password"}),
          input(Forms::Input, state.form_model, :password_confirmation, {type: "password"}),
          input(Forms::WysiTextarea, state.form_model.profile, :bio), # Wysi with image upload image browse fulltext search and shit
          input(Forms::Input, state.form_model.avatar, :file, {type: "file", has_file: true, preview_image: true}), #< preview your avatar before saving user
          if state.current_user.has_role? :admin <== that'll is set by plugin #<= will automatically show if has thanks to DependsOnCurrentUser plugin
            input(Forms::Select, state.form_model, :role, {multiple: true, load_from_server: {url: "/api/test"}}) #select option will be feeded by server
          end,
          t(:br, {}),
          t(:button, {onClick: ->(){handle_inputs}}, "create user")
        )
      )
    end

    def handle_inputs
      collect_inputs 
      unless state.form_model.has_errors?
        state.form_model.attributes[:by_admin] = 1 if state.form_model.has_role? :admin
        state.form_model.create({component: self #needed for spinner only#}, {serialize_as_form: true}).then do |model|
         if model.has_errors?
            set_state form_model: model
          else
            pub_to(:user_created_channel, model)
          end
        end
      else
        set_state form_model: state.form_model
      end
    end
  #####THIS WILL ALL serialize beatifully to form data, will send with all accepts_nested_attributes_for Rails ready
 # everything will be validated shown and checked before sent to server, (even if not defined on client but are on server after request will also be shown where what and how many ), 
  #highlighted and shit. and your dealing with several models at once, image upload preview, fulll assblown WYSIWG (Voog rules), and just look how DRY it is, everything is reusable!
  #all files via XHR without hassle, super duper message BUS between your objects, everything one needs, handy right?
  end
end
```

# VIEWS (React components)

View part is all about react components.
That is done via simple Opal wrapping of the React by RW class (short for React Wrapper). The main idea of wrapping/accessing React's functions taken from [zetachang/react.rb](https://github.com/zetachang/react.rb)) .

Wrapping React I tried to keep it as close to React as possible without fancy-schmancy stuff. 
You should treat and write the components the way you would do with React, but with all the Ruby beautiness (long live Opal!).

### the hello world example 

```
class HelloName < RW
  expose
  def get_initial_state
    {
      name: "Johny"
    }
  end
  def render
    t(:div, {}, 
      t(:p, {}, "Hello #{state.name}!")
    )
  end
end
```


Your RW component should call expose in definition... always ...or it will not work. That expose method exposes RW class to be acessible from outside of Opal (e.g. by reactrails ujs). Calling expose will make Users::LogIn to window["Users_LogIn"], so you can access it from outside.

## native React functions and their RW counterparts:

Name one native method, snake_case it, get the name of RW method.
```
getInitialState #=> will beacome get_initial_state
#should return hash representing state
def get_initial_state
  { foo: "bar", user: User.new({name: "Foo"})}
end
```
```
getDefaultProps #=> self.get_default_props
should return hash representing props
def self.get_default_props
  {name: "Defaulteria"}
end
```
ALL other methods are #underscore representation of functions e.g. 
```
componentWillUpdate -> component_will_update
```
All React's native functions are wrapped in instance methods, except for get_default_props which is a class one, createElement can by used by `#t` method.

All the methods behave absolutely same as vanilla React. And can be used with predictable result.
You can easily mix with JS React Compoonents easily (more on that later).

##### the createElement() method in RW 
```
t(<component_name: Klass < RW || `VanillaComponent(any)` || String || Symbol>, <props : Hash>, *<children>)
```

> t is short for tag and it's short, in case you've wondered why t.

> `children` behave as `*args`, so that means you have to separate them with comma.

> html tags called as strings or symbols (`"div"`, `:button` etc). 

To create RW component simply pass it: `t(Components::Users::Index, {})`

> For vanilla pass their name with backsticks.

#### example:
```
class Components::Users::Messager < RW
  expose
  def render
    t(:div, {}, 
      t(Components::Users::Message, {name: "Johny"},
        t(:p, {}, "first Johny's child"),
        t("h3", {}, "second Johny's child")
      ),
      t(`SomeReactJsClass`, {meg_prop: "foo"}, "Hello was said to Johny")
    )
  end
end
```
 ###### short QA.
  > that's comma separating sucks.
  
  > yeah it does Sir, BUT you'll get used to it in no time, and compiler will show you to the exact line at compile time, so it will not bring you to much of a problem.

## props
props are passed as hash to second arg of `#t`, if no props given be kind to supply an emty Hash `{}`.  
`t(:div, {className: "la-la-la", id: "baz", style: {display: "none"}}, "THE CONTENT")`

**functions to events are added as lambdas**:
```
class Users::Show
  expose
  def initial_state
    { user: User.new(name: "Foo") }
  end
  def render
    t(:div, {className: "html-class"},
      t(:button, {onClick: ->{handler(state.user)}}, 
        "click me for me to shout at you"
      )
    )
  end
  def handler(e)
    alert "get outa here you little #{e.name}"
  end
end
```

##### passing function as props from parent:
```
Components::PropsAsMeth::Example < RW
  expose
  def render
    t(:div, {},
      t(Components::SomeComponent::Screamer, {on_shout: ->(wat){shout(wat)}},
      )
    )
  end
  def on_shout(wat)
    alert wat
  end
end

class Components::SomeComponent::Screamer < RW
  expose
  def render
    t(:button, {onClick: ->{shout_from_parent}}, "shout from parent!")
  end
  
  def shout_from_parent
    props.on_shout("WHAAT!")
  end
end
```   

##### WARNING to use initialize use #init instead in RW component;
```
  class Users::Foo
    def init
      @full_name = "#{props.user.first_name} #{props.user.last_name}"
    end
  end
```
> #init will be called parallel to native getInitiaState() in a lifecycle.

### Refs:
refs are defined traditionally and are so awesome to use with ruby
class Users::Messager < RW
  def render
    t(:div, {}, 
      t(:input, {type: "text", ref: "the_input"}),
      t(:button, {onClick: ->{show_me_input}})
    )
  end

  def show_me_input
    alert ref(:the_input).value
  end
end

> BEWARE STRANGER:
**state, ref, props are accessed as wrapped in Native, they are not ruby structures (but you wont meet any problems with that).**
to get refs as Ruby Hash, you can call `#refs_as_hash`  ruby hash of props is get via `props_to_h`

*But you know what's even more awesome? that you can get the opal instance backing the component*
```
class Foo < RW
  expose
  def initial_state
   { message_of_truth: ""}
  end

  def render
    t(:p, {}, state.message_of_truth)
  end
end

class TheMainComponent < RW
  expose
  def render
    t(:div, {}, 
      t(Foo, {ref: "foo"}),
      t(:p, {onClick: ->{change_state_of_foo}} )
    )
  end
  def change_state_of_foo
    ref(:foo).__opalInstance.set_state message_of_truth: "you are human!"
  end
end
```
## iterations in render
beacuse we roll our little special `#t` method, traditional iterations won't work
```
def initial_state
  x = []
  100.times do |i|
    x << i
  end
  { ar: x }
end

def render
  t(:div, {},
    *splat_each(ar) do |v|
      t(:p, {}, v)
    end
  )
end
```
there are defined `splat_each(enum)` and `splat_each_with_index(enum)`, but you can easily add your
own in simply patching the RW class (or monkey patch the Array or Hash classes), so your iteration returns an array of values returned from it. look at source and youll see why. and star * also should be added before your `splat_iteration_method` (as well as to any arrays that are being passed as children)

    *SHORT QA*
   > q: ...
    
   > a: shh, don't even ask, you'll get used to it super fast. look at it as the situation where vanilla React render function should return single element

### loading data from server example
```
  def initial_state
    {
      user: false
    }
  end

  def component_did_mount
    User.show({id: 1}).then do |_user|
      set_state user: _user
    end
  end

  def render
    t(:div, {}, 
      if state.user
        t(:p, {}, state.user.name)
      else
        t(:p, {}, "not loaded yet")
      end
    )
  end
```

# Controllers

it's shame to call them so, but I'm used to that name, and it's simply a couplea line class 
which has an accessor to Opal RW instance passed to it on new.

I didn't yet find that much of necessity in them, so basically components are controller views themselves.
But for the sake of incapsulation they may be used.

RW components have `assign_controllers(ControllerName)`, which ll be called upon their instantiation,
which pass themselve to provided contorller.  
  *Don't worry when component will unmount everything will be autamatically cleared.

# EXTRAS
React, ReactRouter, History, Zepto are included by default. (javascripts/vendor/)

now it includes couple of plugins
PubSubBus:  
simple observable like pub sub messaging system, refer to vendor/PubSubBus, for working example refer to components/users/login_info and model/CurrentUser

Plugins::Formable:  
super easy form handling, currently inputs for: input {file: true}, text input, textarea, select with feed from server, wysi_textarea for wrapped Voog's wysihtml. look at source in components/forms and plugins/formable

bootstrap modal and dropdowns, working example menues/index, pages/new click on insert image on textarea

Pagination (integration wih will paginate) for working : for working example pages/index

DependsOnCurrentUser , render stuff that depends on user permissions, for working example dashboards/admin  click add user with admin and non admin user

###### END NOTES
For more info refer to source itself. I've tried to comment code as much as I could.  
start from components/app/router components/app/main, load click everywhere, watch the demo components source, than proceed to vendor/model, vendor/react_wrapper.    

one day you approach me in the dusk, and ask: "dude what the fuck is this? where are tests at least", and you'll se me putting on my hood masking my face, and me dissapearing in the shadows.


Thank you for scrolling to here!


###LICENSE


DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
                    Version 2, December 2004 

 Copyright (C) 2015 classyPimp 

 Everyone is permitted to copy and distribute verbatim or modified 
 copies of this license document, and changing it is allowed as long 
 as the name is changed. 

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION 

  0. You just DO WHAT THE FUCK YOU WANT TO.
