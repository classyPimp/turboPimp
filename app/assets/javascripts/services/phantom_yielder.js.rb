module Services
  class PhantomYielder

    def self.instance
      @instance ||= self.new
    end

    def self.instance=(val)
      @instance = val
    end

    def initialize(component_count)
      @not_ready_components_count = component_count
    end

    def one_component_ready
      @not_ready_components_count -= 1
      if @not_ready_components_count == 0
        inform_phantom_of_readyness
      end
    end

    def inform_phantom_of_readyness
      x = ->{`if (typeof window.callPhantom === 'function') {
        window.callPhantom('components_ready');
      }`}
      x.call
      p 'all loaded'
    end

  end
end