module Forms
  class Checkbox < RW
    expose

    #PROPS
    # checked: Boolean

    def __component_will_update__
      ref("#{self}").value = "" if props.reset_value == true
      super
    end

    def valid_or_not?
      if props.model.errors[:attr]
        "invalid"
      else
        "valid"
      end
    end

    def get_initial_state
      {
        checked: props.checked,
        check_value: props.check_value ? props.check_value : "1"
      }
    end

    def options
      opts = {}
      state.checked ? (opts[:checked] = "checked") : nil
      opts
    end

    def render
      t(:div, {className: "chekbox_holder #{valid_or_not?}"},
        *if props.model.errors[props.attr]
          splat_each(props.model.errors[props.attr]) do |er|
            t(:div, {className: 'errors'},
              t(:p, {},
                er
              ),
              t(:br, {})    
            )             
          end
        end,
        t(:input, {className: "checkbox", type: "checkbox", 
                   key: props.keyed, onChange: ->{check}}.merge(options)),
        t(:p, {className: 'show_name'}, "#{props.show_name}"),
        children      
      )   
    end

    def check
      set_state checked: !state.checked
      if props.to_call_on_change
        emit(:to_call_on_change)
      end
    end

    def collect
      props.model.attributes[props.attr.to_sym] = state.checked ? state.check_value : ""  
    end

    def clear_inputs
      ref("#{self}").value = ""
    end

  end
end