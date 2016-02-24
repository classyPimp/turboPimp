module Forms
  class Textarea < RW
    expose

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

    def render
      t(:div, {},
        if props.show_name
          props.show_name
        else
          t(:p, {}, props.attr)
        end,
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
        t(:textarea, {className: valid_or_not?, defaultValue: props.model.attributes[props.attr], ref: "#{self}", 
                      key: props.keyed}),
        children      
      )   
    end

    def collect
      if props.has_file 
        props.model.attributes[props.attr.to_sym] = ref("#{self}").files[0]
      else
        props.model.attributes[props.attr.to_sym] = ref("#{self}").value
      end
    end

    def clear_inputs
      ref("#{self}").value = ""
    end

  end
end