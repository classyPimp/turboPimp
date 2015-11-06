module Forms
  class Input < RW
    expose_as_native_component

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
        t(:input, {className: valid_or_not?, defaultValue: props.model.attributes[props.attr], ref: "#{self}", 
        type: props.type, key: props.keyed}),
        children      
      )   
    end

    def collect
      props.model.attributes[props.attr.to_sym] = ref("#{self}").value
    end
  end
end