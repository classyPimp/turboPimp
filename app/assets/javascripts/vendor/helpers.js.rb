require "./model"

module Helpers
  
  class Cookie
    def self.get()
      c = `document.cookie`
      x = c.include? "l="
    end
  end

  class ::RW
    
    
  #### REACT ROUTER HELPERS
    def link_to(body, link, options = {})
     if block_given?
      body = yield
     end
      t(`Link`, {to: link, query: options.to_n}, body)    
    end

    def route(options, *args)
      if options[:component].is_a? RW
        options[:component] = options[:component].create_class
      end
      t(`Route`, options, *args)
    end
  ###### /REACT ROUTER HELPERS
  #####   SPINNER
    attr_accessor :has_spinner

    require "components/shared/spinner"

    def spinner(display = "none")
      @has_spinner = true
      t(Shared::Spinner, {ref: "spinner", display: display})
    end

    def spinner_instance
      ref(:spinner).rb
    end
  #####   /SPINNER

  #####     MODAL
    ### INCLUDES BOOTSTRAP MODAL HELPER
    # in render simply call modal({className: "something"}, 
    #  t(:p, {},"foobar")
    #)
    # you can call modal_open(passing head, and content)
    #
    require "components/shared/modal"

    def modal(options = {}, passed_children = `null`)
      options[:ref] = "modal"
      t(Shared::Modal, options, 
        passed_children
      )
    end

    def modal_instance
      ref(:modal).rb
    end

    def modal_open(head_content = false, content = false)
      modal_instance.open(head_content, content)
    end

    def modal_close(preserve = false)
      modal_instance.close(preserve)
    end
  ######    \MODAL
  end

  class ::RequestHandler

    def defaults_on_response
      authorize!
      (@component.spinner_instance.off if @component.has_spinner) if @component
      if @response.status_code == 404
        Components::App::Router.history.replaceState(nil, "/404")
      elsif @response.status_code == 500
        Components::App::Router.history.replaceState(nil, "/505?status_code=500")
      elsif @response.status_code == 400
        Components::App::Router.history.replaceState(nil, "/505?status_code=400")
      end
    end

    def defaults_before_request
      (@component.spinner_instance.on if @component.has_spinner) if @component
    end

    def authorize!
      #obvious
      if @response.status_code == 403
        Components::App::Router.history.replaceState(nil, "/forbidden")
      end
    end
  end

  module UpdateOnSetStateOnly
    #Including to RW component, will make it updatetable only from calling set_state on corresponding instance
    #ither way it always should_component_update == false

    def __component_did_mount__(*args)
      super *args
      @should_update = false 
    end

    def __set_state__(val)
      @should_update = true
      super val
    end

    def __component_did_update__(*args)
      super *args
      @should_update = false
    end

    def __should_component_update__(*args)
      @should_update
    end
  end

  module PubSubBus

    


  #Sort of observable, but user objects subcsribe to channels
    #Observable publishes to channels, objects that subscribed to that channel must implement method same as
    #channel name.
    #To make it a but strict observable object must call .allowed_channels at classs body passing channel names
    #example
#  class Foo
#    
#    include PubSubBus
#    allowed_channels :on_foo_update, :on_foo_secret
#  end
#
#  class Bar
#    
#    def initialize(foo)
#      foo.subscribe(:on_not_imp, self)
#      => WILL THROW :on_not_imp not allowed channel
#      foo.subscribe(:on_foo_update, self)
#      => will THROW bar must implement :on_update method
#      #unless bar respond_to? :on_update
#    end
#
#    def on_foo_update(foo)
#      p "foo from Bar"
#    end
#  end
#
#  foo = Foo.new
#  bar = Bar.new(foo)
#  foo.pub_to(:on_foo_update, "foo") 
#  => "foo from Bar"
#  foo.unsub_from(:on_foo_update, bar)


    def self.extended(base)
      base.pub_sub_list_init
    end

    def pub_sub_list_init
      @pub_sub_list = {}
    end

    def pub_sub_list
      @pub_sub_list
    end

    def allowed_channels(*args)
      args.each do |arg|
        @pub_sub_list[arg] = []
      end
    end

    def sub_to(channel, obj)
      if @pub_sub_list[channel].is_a? Array
        raise "#{obj} does'nt implement #{channel} method needed for sub_to #{self}" unless obj.respond_to? channel
        @pub_sub_list[channel] << obj 
      else
        raise "#{self} attempt to sub_to unallowed channel by #{obj}"
      end
    end

    def pub_to(channel, *args)
      raise "#{self} tried to pub_to unallowed: #{channel}" unless @pub_sub_list[channel]
      @pub_sub_list[channel].each do |obj|
        obj.public_send(channel, *args)
      end
    end

    def unsub_from(channel, obj)
      raise "#{obj} tried to #{self}.unsub_from #{channel} which is not in list" unless @pub_sub_list[channel]
      @pub_sub_list[channel].delete(obj)
    end

  end

end