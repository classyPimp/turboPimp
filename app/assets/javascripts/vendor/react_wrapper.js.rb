=begin
For safe custom additions there is helpers module.
You can monkey patch RW, Model there or anything else there. (reminder it was hard for me to make RW as module that is included in each component
, beacuse in some cases to modify RW (by including module in it was not possible because of dependecy loading), the exit was either including
other methods, like include RW; include Helpers; include Etc in each component but that is more typing; so I decided to stay with monkey 
patching everything in helpers file)


=end



require 'native'

`
window.Router = ReactRouter.Router
window.Route = ReactRouter.Route
window.Link = ReactRouter.Link
window.IndexRoute = ReactRouter.IndexRoute
window.browserHistory = window.History.createHistory
`

class RW
   
  class << self
    def native_name
      @native_name ||= self.name.split('::').join('_') # that face is looking right in your soul
    end
  end

  def self.expose
    `window[#{native_name}] = #{self.create_class}`
  end

  attr_accessor :controller

  def initialize(native)
    @native = Native(native)
    init
    assign_controller
    #validate props.
    #decided to user this for props validation, the validate_props should be implemented the way you want.
    validate_props
  end

  def validate_props
    
  end

  def assign_controller
    
  end

  def init
    
  end

  def self.default_props
    
  end

  def __get_initial_state__
    `var x = {}`
    if get_initial_state
      self.get_initial_state.each do |k,v|
        `x[#{k}] = #{v}`
      end
    end
    `x`
  end

  def get_initial_state
    
  end

  def component_will_mount
    
  end

  def component_did_mount
    
  end

  def clear_controllers
    unless @controller == nil
      @controller.component = nil
      @controller = nil
    end
  end

  def __component_will_unmount__
    clear_controllers
    component_will_unmount
  end

  def component_will_unmount
    
  end

  def __component_will_update__(next_props, next_state)
    component_will_update(next_props, next_state)
  end

  def component_will_update
    
  end

  def __should_component_update__(next_props, next_state)
    should_component_update(Native(next_props), Native(next_state))
  end

  def should_component_update(next_props, next_state)
    true
  end

  def __component_will_receive_props__(next_props)
    component_will_receive_props(next_props)
  end

  def component_will_receive_props(next_props)
    
  end

  def __component_did_update__(prev_props, prev_state)
    component_did_update(Native(prev_props), Native(prev_state))
  end

  def component_did_update(prev_props, prev_state)

  end

  def self.create_class()
    (%x{
        React.createClass({
          getDefaultProps: function(){
            return #{self.default_props.to_n};
          },
          getInitialState: function(){
            this.rb = #{self.new(`this`)}
            return #{`this.rb.$__get_initial_state__()`};
          },
          componentWillMount: function() {
            return this.rb.$component_will_mount();
          },
          componentDidMount: function() {
            return this.rb.$component_did_mount();
          },
          componentWillReceiveProps: function(next_props) {
            return this.rb.$__component_will_receive_props__(next_props);
          },
          shouldComponentUpdate: function(next_props, next_state) {
            return this.rb.$__should_component_update__(next_props, next_state);
          },
          componentWillUpdate: function(next_props, next_state) {
            return this.rb.$__component_will_update__(next_props, next_state);
          },
          componentDidUpdate: function(prev_props, prev_state) {
            return this.rb.$__component_did_update__(prev_props, prev_state);
          },
          componentWillUnmount: function() {
            return this.rb.$__component_will_unmount__();
          },
          displayName: #{self.to_s},
          render: function() {
            return this.rb.$render();
          }
        })
    })
  end

  def render
    
  end

  def props
   @native.props
  # Native(`#{@native.to_n}.props`)   
  end

  def props_as_hash(prop)
    Hash.new(`#{@native.to_n}.props[#{prop}]`)
  end

  def state
    @native.state
    #Native(`#{@native.to_n}.state`)
  end

  def state_to_h
    Hash.new(state.to_n)
  end

  def ref(ref)
    @native.refs[ref]
    #Native(`#{@native.to_n}.refs[#{ref}]`)
  end

  def refs
    Hash.new @native.refs.to_n
  end

  def children
    props.children.to_n
  end

  def set_state(val)
    __set_state__(val)
    x = `{}`
    val.each do |k,v|
      `#{x}[#{k}] = #{v}`
    end
    @native.setState(x)
    #`#{@native.to_n}.setState(#{x})`
  end

  def __set_state__(val)
    
  end

  def splat_each(enum)
    x = []
    enum.each do |val|
    x << yield(val)
    end
    x
  end

  def splat_each_with_index(enum, option = nil)
    x = []
    enum.each_with_index do |v,i|
      x << yield(v, i, option)
    end
    x
  end


  def t(_klass, _props = {}, *args)
    
    #t is short for tag
    #creates react element   
#=begin
#it's must be changed in react library

#in traverseAllChildrenImpl function
#
#  function traverseAllChildrenImpl(children, nameSoFar, callback, traverseContext) {
#  var type = typeof children;
#
#  if (type === 'undefined' || type === 'boolean' || children === Opal.nil) { <<<<<<<<< || children === Opal.nil was added
#    // All of the above are perceived as null.
#    children = null;
#  }
#
#THE REASON BEHIND:
#before args were compacted! to remove nils (e.g. if in render there was and if statement which returned nil)
#I thought that it's bad to traverse all children each time, so instead I altered react itself.
#That's a little hack and I don't think it'll be hard to do with further coming versions of React, beacuse even if
#traverseAllChildrenImpl be implemented in other way there would easily be place for checking if child is Opal.nil
#if you don't want to mess with react core simply uncomment params.compact!

#=end
    unless _klass.is_a? String
      _klass = `window[#{_klass.native_name}]` unless _klass.is_a?(Proc)
    end

    `var x = {}`
    _props.each do |k,v|
      `x[#{k}] = #{v}`
    end
    
    if args.empty?
      params = [_klass, `x`]
    else
      params = [_klass, `x`, *args]
    end
    #params.compact!
    (%x{
      React.createElement.apply(null, #{params})
    })
  end

  def force_update
    @native.forceUpdate
  end


#props as procs
#for some reason in some cases if prop is assigned with proc it's being lost
#for this reason ProcEvent class will as container for pros (for props event)
#as extra plus it gives more explicity for events as well can be enriched with features
#also it can be changed anyway needed cause only event emit accessed so it's basically adapterable of some sort. 
  def event(proc)
    ProcEvent.new(proc)
  end

  def emit(prop_name, *args)
    props[prop_name].call(*args)
  end

  class ProcEvent
    def initialize(proc)
      @proc = proc
    end

    def call(*args)
      @proc.call(*args)
    end
  end
# END props as procs
end
