module Services
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

    def self.included(base)
      base.extend(self::ToExtend)
      base.extend(self::ClassMethods)
      base.include(self::InstanceMethods)
    end
    
    module ClassMethods
      def sub_to(channel, obj)
        if @pub_sub_list[:class][channel].is_a? Array
          @pub_sub_list[:class][channel] << obj 
        else
          raise "#{self} attempt to sub_to unallowed channel by #{obj}"
        end
      end

      def pub_to(channel, *args)
        raise "#{self} tried to pub_to unallowed: #{channel}" unless @pub_sub_list[:class][channel]
        @pub_sub_list[:class][channel].each do |obj|
          begin
          obj.public_send(channel, *args)
          rescue NoMethodError => e
            raise "#{self} tried to pub to #{channel} but #{obj} doesn't implement it"
          end
        end
      end

      def unsub_from(channel, obj)
        x = @pub_sub_list[:class][channel].delete(obj)
        raise "#{obj} tried to #{self}.unsub_from #{channel} which is not in list" unless x
      end
    end

    module InstanceMethods
      def sub_to(channel, obj)
        p self.class.pub_sub_list
        if self.class.pub_sub_list[:instance][channel].is_a? Array
          self.class.pub_sub_list[:instance][channel] << obj 
        else
          raise "#{self} attempt to sub_to #{obj} to unallowed channel"
        end
      end

      def pub_to(channel, *args)
        raise "#{self} tried to pub_to unallowed: #{channel}" unless self.class.pub_sub_list[:instance][channel]
        self.class.pub_sub_list[:instance][channel].each do |obj|
          begin
          obj.send(channel, *args)
          rescue NoMethodError => e
            raise "#{self} tried to pub to #{channel} but #{obj} doesn't implement it: #{e}"
          end
        end
      end

      def unsub_from(channel, obj)
        x = self.class.pub_sub_list[:instance][channel].delete(obj)
        raise "#{obj} tried to #{self}.unsub_from #{channel} which is not in list" unless x
      end 

    end

    module ToExtend
      def pub_sub_list
        @pub_sub_list
      end

      def pub_sub_list=(val)
        @pub_sub_list = val
      end

      def allowed_channels(arg)
        (@pub_sub_list = {})[:class] = {}
        @pub_sub_list[:instance] = {}
        @allowed_channels = arg
        @allowed_channels[:class].try("each") do |channel|
          @pub_sub_list[:class][channel] = []
        end
        @allowed_channels[:instance].try("each") do |channel|
          @pub_sub_list[:instance][channel] = []
        end
      end

      def implemented_channels(arg)
        @implemented_channels = arg
        @implemented_channels[:class].try("each") do |channel|
          raise "class channel #{channel} not implemented for #{self} but declared as so" unless self.respond_to? channel
        end
        @implemented_channels[:instance].try("each") do |channel|
          raise "instance channel #{channel} not implemented for #{self} but declared as so" unless self.method_defined? channel
        end
      end
    end

  end
end