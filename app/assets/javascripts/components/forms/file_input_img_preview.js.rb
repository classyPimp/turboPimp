module Forms
  class FileInputImgPreview < RW
    expose
    
    def __component_will_update__
      ref("#{self}").value = "" if props.reset_value == true
      super
    end

    def get_initial_state
      {
        errors: false
      }
    end

    def component_will_receive_props(next_props)
      next_props = Native(next_props)
      if x = next_props.model.errors[props.attr]
        set_state errors: x, uploaded: false, image_to_preview: false
      else
        set_state errors: false
      end
    end

    def valid_or_not?
      if props.model.errors[props.attr]
        "invalid"
      else
        "valid"
      end
    end

    def optional_props
      props.input_props || {}
    end

    def get_initial_state
      {
        image_to_preview: false,
        counter: 0 #this needed because of weird bug of not rendering errors
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
        #{set_state image_to_preview: false};
      }
      `
    end

    def combined_errors
      x = props.model.errors[props.attr]
      y = props.model.errors[props.show_errors_for]
      x = (x.is_a? Array) ? x : [] #for some reason ||= didn't work for Opal in this situation
      y = (y.is_a? Array) ? y : []
      z = x + y
      z      
    end


    def render

      comp_options = props.comp_options ? props.comp_options : {}

      t(:div, comp_options.merge({className: "form_input #{comp_options[:className]} #{valid_or_not?}"}),

        t(:div, {key: state.counter},
          *if state.errors
            splat_each(state.errors) do |er|
              t(:p, {}, "#{er}")
            end
          end
        ),
        if state.uploaded
          t(:div, {},
            t(:p, {}, "selected file: #{props.model.attributes[props.attr].name}"),
            t(:button, {onClick: ->{cancel_upload}}, 'cancel')
          )
        end,
        t(:div, {className: 'label_holder'},
          t(:label, {className: 'file_input_container'},
            if state.uploaded
              t(:button, {className: 'upload_button'}, 'select another')
            else
              t(:button, {className: 'upload_button'}, 'upload file')
            end, 
            t(:input, {className: "#{valid_or_not?} form_input_input", ref: "#{self}", 
                       type: 'file', key: props.keyed, onChange: ->{handle_change}}.merge(optional_props)),
          )
        ),
        if state.image_to_preview
          t(:div, {className: "image_preview"},
            t(:img, {className: 'image_to_preview', src: state.image_to_preview, alt: "image_preview" })
          )
        end
      )   
    end

    def handle_change
      x = ref("#{self}").files[0]
      if x
        props.model.attributes[props.attr] = ref("#{self}").files[0] || ""
        set_state uploaded: true
      else
        props.model.attributes[props.attr] = ""
        set_state uploaded: false
      end
      preview_image
    end

    def collect
      props.model.attributes[props.attr] = ref("#{self}").files[0] || ""
      set_state counter: (state.counter += 1)
    end

    def cancel_upload
      clear_inputs
      props.model.attributes[props.attr] = ''
      set_state uploaded: false, image_to_preview: false
    end

    def clear_inputs
      ref("#{self}").value = ""
    end

  end
end