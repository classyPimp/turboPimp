module Shared
  class ThinProgressBar < RW
    expose

    def validate_props
      if props.interval == nil || !props.interval.is_a?(Integer)
        raise "#{self.class.name} #{self} props.interval"
      end
    end

    def get_initial_state
      {
        width: 0
      }
    end

    def render
      t(:div, {}, 
        t(:div, {className: 'progress thin_progress'}, 
          t(:div, {className: 'progress-bar', role: 'progressbar', style: {width: "#{state.width}%"}.to_n}, 
          )
        )
      )
    end

    def component_did_mount
      start_interval_update
    end

    def component_will_unmount
      stop_interval
    end

    def start_interval_update
      if props.interval
        x = props.interval.to_i
        @intervaller = Services::MessagesPoller.new(x) do
          if state.width < 90
            set_state width: (state.width += 10)
          end
        end
        @intervaller.start
      end
    end

    def stop_interval
      @intervaller.stop
    end


    def set_full_width
      p 'setting to full'
      set_state width: 100 
    end

    def reset_width
      p 'setting to 0'
      set_state width: 0
    end

  end
end
