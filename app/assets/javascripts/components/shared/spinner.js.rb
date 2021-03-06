require "vendor/react_wrapper"
module Shared
  class Spinner < RW
    expose

    def get_initial_state
      on = props.display ? props.display : "none"
      {
        on: on
      }
    end

    def render
      t(:div, {className: "cssload-container", style: {display: state.on}.to_n}, 
        t(:div, {className: "cssload-speeding-wheel"})
      )
    end

    def on
      set_state(on: "inline") if state.on == "none"
    end

    def off
      set_state(on: "none") unless state.on == "none" 
    end
  end
end