module Forms
  class PushCheckBox < RW
    expose

    #PROPS
    # checked: Boolean

    def __component_will_update__
      ref("#{self}").value = nil if props.reset_value == true
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
        checked: props.checked
      }
    end

    def options
      opts = {}
      state.checked ? (opts[:checked] = "checked") : nil
      opts
    end

    def render
      t(:div, {},
        t(:p, {}, props.attr),
        *if props.model.errors[props.attr]
          splat_each(props.model.errors[props.attr]) do |er|
            t(:div, {},
              t(:p, {},
                er
              ),
              t(:br, {})    
            )             
          end
        end,
        t(:input, {className: valid_or_not?, type: "checkbox", 
                   key: props.keyed, onClick: ->{check}}.merge(options)),
        children      
      )   
    end

    def check
      set_state checked: !state.checked
    end

    def collect
      props.push_value.allow_to_n if props.push_value.is_a? Hash
      if props.model.attributes[props.attr].is_a? Hash
        if state.checked
          props.model.attributes[props.attr].additive_merge!(props.push_value)
        else
          props.model.attributes[props.attr].subtractive_merge!(props.push_value)
        end
      elsif props.model.attributes[props.attr].is_a? Array
        if state.checked
          props.model.attributes[props.attr] << props.push_value
        end
      end
    end

    def clear_inputs
      ref("#{self}").value = nil
    end
  end
end