module Forms
  class Input < RW
    expose
    ##PROPS
    # input_props: Hash, this'll go to input
    # comp_props: Hash, this'll go to components main div
    # show_name: String, this ill be shown near the input as input name
    # show_errors_for: String, will merge errors for this attr (eg. in form it is :user, but server returns errors for :user_id)
    # NOT ALL LISTED
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

    def optional_props
      opt = Hash.new(props.input_props.to_n)
      if props.preview_image
        opt[:onChange] = ->(){preview_image}
      end
      unless opt[:placeholder]
        opt[:defaultValue] = props.model.attributes[props.attr]
      end
      opt
    end

    def get_initial_state
      {
        image_to_preview: ""
      } 
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

    def combined_errors
      x = props.model.errors[props.attr].clone
      y = props.model.errors[props.show_errors_for].clone
      x = (x.is_a? Array) ? x : [] #for some reason ||= didn't work for Opal in this situation
      y = (y.is_a? Array) ? y : []
      x + y      
    end

    def render
      comp_options = props.comp_options ? props.comp_options : {}
      t(:div, comp_options,
        t(:p, {}, "#{(props.show_name || props.attr)}"),
        *if props.model.errors[props.attr] || props.model.errors[props.show_errors_for] 
          splat_each(combined_errors) do |er|
            t(:div, {},
              t(:p, {},
                er
              ),
              t(:br, {})    
            )             
          end
        end,
        t(:input, {className: valid_or_not?, ref: "#{self}", 
                   type: props.type, key: props.keyed}.merge(optional_props)),
        if props.preview_image && state.image_to_preview != ""
          t(:div, {className: "image_preview"},
            t(:div, {style: {width: "300px", height: "300px"}},
              t(:img, {src: state.image_to_preview, alt: "image_preview", style: {width: "300px", height: "300px"}.to_n })
            )
          )
        end,
        children      
      )   
    end

    def collect
      if props.has_file 
        props.model.attributes[props.attr.to_sym] = ref("#{self}").files[0] || ""
        #props.model.attributes[props.attr.to_sym] = "" if props.model.attributes[props.attr.to_sym] == nil
      else
        props.model.attributes[props.attr.to_sym] = ref("#{self}").value
      end
    end

    def clear_inputs
      ref("#{self}").value = ""
    end
  end
end