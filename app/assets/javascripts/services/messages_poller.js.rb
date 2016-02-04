module Services
  class MessagesPoller

    def initialize(rate, &block)
      @proc = block
      @rate = rate
    end

    def start
      p 'started'
      @interval = %x{
        setInterval(function(){ #{ @proc.call } }, #{@rate})
      }
    end

    def stop
      p "stopping #{self.class.name} #{self} "
      %x{
        clearInterval(#{@interval})
      }
    end

  end
end