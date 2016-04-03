module Shared
  class ProgressBar < RW
    expose


    def get_initial_state
      {
        width: 10,
        on: false,
      }
    end

    def render 
      display = state.on ? '' : 'none'
      t(:div, {className: 'progress thin_progress', style: {display: display}.to_n}, 
        t(:div, {className: 'progress-bar', role: 'progressbar', style: {width: "#{state.width}%"}.to_n}, 
        )
      )
    end

    def component_will_unmount
      stop_interval if state.on
    end

    def on
      unless state.on
        @intervaller = Services::Interval.new(75) do
          if state.width < 90
            set_state width: (state.width += 10)
          end
        end
        set_state on: true, width: 0
        @intervaller.start
      end
    end

    def off
      set_state width: 100
      stop_interval
      %x{
        setTimeout(function(){ #{set_state on: false, width: 0} }, 200);
      }
    end

    def stop_interval
      @intervaller.stop
    end

  end
end
