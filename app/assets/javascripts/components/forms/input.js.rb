module Forms
  class Input < RW
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

    def on_change_options
      if props.preview_image
        {onChange: ->(){preview_image}}
      else
        {}
      end
    end

    def initial_state
      {
        image_to_preview: ""
      } 
    end


    def component_did_update
      p "updated"
    end

    def preview_image
      `
      var file    = #{ref("#{self}").files[0].to_n};
      var reader  = new FileReader();

      reader.onloadend = function () {
        #{set_state image_to_preview: `reader.result`};
      }

      if (file) {
        reader.readAsDataURL(file);
      } else {
        #{set_state image_to_preview: ""};
      }
      `
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
                   type: props.type, key: props.keyed}.merge(on_change_options)),
        if props.preview_image
          t(:div, {className: "image_preview"},
            t(:div, {style: {width: "300px", height: "300px"}},
              t(:img, {src: state.image_to_preview, alt: "image_preview"})
            )
          )
        end,
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