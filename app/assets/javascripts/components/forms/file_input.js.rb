module Forms
  class FileInput < RW
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

    def optional_props
      props.input_props || {}
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

      t(:div, comp_options.merge({className: "form_input #{comp_options[:className]}"}),
        t(:p, {className: 'form_input_label x'}, "#{(props.show_name || props.attr)}"),
        *if props.model.errors[props.attr] || props.model.errors[props.show_errors_for] 
          p "yeah got errors"
          splat_each(combined_errors) do |er|
            t(:div, {className: 'individual_error'},
              t(:p, {},
                er
              ) 
            )             
          end
        end,
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
        children
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
    end

    def collect
      props.model.attributes[props.attr] = ref("#{self}").files[0] || ""
    end

    def cancel_upload
      clear_inputs
      props.model.attributes[props.attr] = ''
      set_state uploaded: false
    end

    def clear_inputs
      ref("#{self}").value = ""
    end
  end
end