module Shared
  class Dropdown < RW

    expose

    def initial_state
      {
        open: false
      }
    end

    def render
      t(:li, {onMouseEnter: ->(){toggle(true)}, onMouseLeave: ->(){toggle(false)}, className: "dropdown #{state.open ? "open" : ""}"},
        t(:a, {role: "button", 
               "aria-haspopup" => "true", "aria-expanded" => "false"}, "#{props.text_val}", t(:span, {className: "caret"})),
        children
      )
    end

    def toggle(arg)
      set_state open: arg
      clear_opened
    end

    def clear_opened
      props.on_toggle(self)
    end

  end
end