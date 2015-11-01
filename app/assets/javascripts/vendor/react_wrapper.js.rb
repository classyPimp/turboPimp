=begin
For safe custom additions there is helpers module.
You can monkey patch RW, Model there or anything else there. (reminder it was hard for me to make RW as module that is included in each component
, beacuse in some cases to modify RW (by including module in it was not possible because of dependecy loading), the exit was either including
other methods, like include RW; include Helpers; include Etc in each component but that is more typing; so I decided to stay with monkey 
patching everything in hepers file)

=end


require 'native'

`
window.Router = ReactRouter.Router
window.Route = ReactRouter.Route
window.Link = ReactRouter.Link
window.History = require('history/lib/createBrowserHistory')
`

class RW
   
  class << self
    def native_name
      @native_name ||= self.name.split('::').join('_') # joins the face lol
    end
  end

  def self.expose_as_native_component
    `window[#{native_name}] = #{self.create_class}`
  end

  attr_accessor :controller

  def initialize(native)
    @native = Native(native)
    init
    assign_controller
  end

  def assign_controller
    
  end

  def init
    
  end

  def self.default_props
    
  end

  def initial_state
    
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

  def self.create_class()
    (%x{
        React.createClass({
          propselfs: #{self.respond_to?(:prop_selfs) ? self.prop_selfs.to_n : `{}`},
          getDefaultProps: function(){
            return #{self.respond_to?(:default_props) ? self.default_props.to_n : `{}`};
          },
          getInitialState: function(){
            var instance = this._getOpalInstance.apply(this);
            return #{`instance`.initial_state.to_n if self.method_defined? :initial_state};
          },
          componentWillMount: function() {
            var instance = this._getOpalInstance.apply(this);
            return #{`instance`.component_will_mount if self.method_defined? :component_will_mount};
          },
          componentDidMount: function() {
            var instance = this._getOpalInstance.apply(this);
            return #{`instance`.component_did_mount if self.method_defined? :component_did_mount};
          },
          componentWillReceiveProps: function(next_props) {
            var instance = this._getOpalInstance.apply(this);
            return #{`instance`.component_will_receive_props(`next_props`) if self.method_defined? :component_will_receive_props};
          },
          shouldComponentUpdate: function(next_props, next_state) {
            var instance = this._getOpalInstance.apply(this);
            return #{`instance`.should_component_update?(`next_props`, `next_state`) if self.method_defined? :should_component_update?};
          },
          componentWillUpdate: function(next_props, next_state) {
            var instance = this._getOpalInstance.apply(this);
            return #{`instance`.component_will_update(`next_props`, `next_state`) if self.method_defined? :component_will_update};
          },
          componentDidUpdate: function(prev_props, prev_state) {
            var instance = this._getOpalInstance.apply(this);
            return #{`instance`.component_did_update(`prev_props`, `prev_state`) if self.method_defined? :component_did_update};
          },
          componentWillUnmount: function() {
            var instance = this._getOpalInstance.apply(this);
            return #{`instance`.__component_will_unmount__};
          },
          _getOpalInstance: function() {
            if (this.__opalInstance == undefined) {
              var instance = #{self.new(`this`)};
            } else {
              var instance = this.__opalInstance;
            }
            this.__opalInstance = instance;
            return instance;
          },
          displayName: #{self.to_s},
          render: function() {
            var instance = this._getOpalInstance.apply(this);
            return instance.$render();
          }
        })
    })
  end

  def render
    
  end

  def props
    Native(`#{@native.to_n}.props`)
  end

  def props_as_hash(prop)
    Hash.new(`#{@native.to_n}.props[#{prop}]`)
  end

  def state
    Native(`#{@native.to_n}.state`)
  end

  def state_to_h(_state)
    Hash.new(state[_state].to_n)
  end

  def ref(ref)
    Native(`#{@native.to_n}.refs[#{ref}]`)
  end

  def children
    props.children.to_n
  end

  def set_state(val)
    `#{@native.to_n}.setState(#{val.to_n})`
  end

  def self.initial_state
    
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
    # if _klass not string counts _klass as react component else counts
    #it as string tag
    
    unless _klass.is_a? String
      _klass = `window[#{_klass.native_name}]` unless _klass.is_a?(Proc)
    end

    if args.length == 0
      params = [_klass, _props.to_n]
    else
      args.compact!
      params = [_klass, _props.to_n, *args]
    end

    (%x{
      React.createElement.apply(null, #{params})
    })
  end

  def update!
    @native.forceUpdate
  end
  
end





