module Services
  module PubSubBus
    module Publisher
    
      def when(channel, &block)
        @block_channels ||= Hash.new { |k, v| k[v] = [] }
        @block_channels[channel] << block 
      end
      
      def subscribe(channel, obj)
        @pub_sub_list = Hash.new { |h, k| h[k] = [] }
        @pub_sub_list[channel] << obj 
      end

      def publish(channel, *args)
        if @pub_sub_list      
          @pub_sub_list[channel].each do |obj|
            begin
            obj.send(channel, *args)
            rescue NoMethodError => e
              raise "#{self} tried to publish to #{channel} but #{obj} doesn't implement it: #{e}"
            end
          end
        end
        if @block_channels
          @block_channels[channel].each do |block|
            block.call(*args)
          end
        end
      end

      def unsubscribe(channel, obj)
        x = @pub_sub_list[channel].delete(obj)
        raise "#{obj} tried to #{self}.unsub_from #{channel} which is not in list" unless x
      end

      def unsubscribe_all(channel = false)
        if channel
          @pub_sub_list[channel] = []
        else
          @pub_sub_list = Hash.new { |h, k| h[k] = []} unless channel
          @block_channels = Hash.new { |k, v| k[v] = [] }
        end
      end 

    end

    module Subscriber
      def implemented_channels(arg)
        @implemented_channels = {}
        @implemented_channels[:class] = []
        @implemented_channels[:instance] = []
        @implemented_channels[:class].each do |channel|
          raise "class channel #{channel} not implemented for #{self} but declared as so" unless self.respond_to? channel
        end
        @implemented_channels[:instance].each do |channel|
          raise "instance channel #{channel} not implemented for #{self} but declared as so" unless self.method_defined? channel
        end
      end
    end

  end
end