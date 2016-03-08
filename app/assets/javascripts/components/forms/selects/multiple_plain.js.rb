module Forms
  module Selects

    class MultiplePlain < RW
      expose
      #PROPS
      #server_feed: {url: #{url}}

      def component_did_mount
        @form_model_value = props.model.attributes[props.attr] || []
        define_options_source
      end

      def get_intial_state
        {
          selected: [],
          options: [],
          open: false
        }
      end

      def define_options_source
        if props.server_feed
          case_server_feed
        else
          case_no_server_feed
        end
      end

      def case_server_feed
        HTTP.post(s_f[:url], payload: s_f[:extra_params]).then do |response|
          prepare_options(SelectOption.new(JSON.parse(response)))
        end
      end

      def case_no_server_feed
        prepare_options(props.options)
      end

      def prepare_options(options)
        options_to_set = []
        
        if props.allow_blank
          options_to_set.unshift(SelectOption.new(value: ''))
        end

        selected_to_set = []

        options.each do |option|
          if @form_model_value.include?(option.value) 
            selected_to_set << option
          else
            options_to_set << option
          end
        end

        set_state selected: selected_to_set, options: options_to_set
      
      end

      def render
        if state.selected
          t(:div, {className: "dropdown #{state.open ? "open" : ""}"},
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
            t(:div, {className: "input-group"},
              t(:div, {className: "input-group-btn"},
                t(:button, {role: "button", "aria-haspopup" => "true", "aria-expanded" => "#{state.open ? "true" : "false"}",
                            className: "btn btn-default", onClick: ->{toggle_dropdown}},
                  t(:span, {className: "caret"})
                )
              ),
              t(:div, {className: "form-control"},
                t(:p, {},
                  *splat_each(state.selected) do |selected|
                    t(:span, {className: "label label-default", style: {cursor: "pointer"}.to_n, onClick: ->{deselect(selected)}},
                      selected.show_value        
                    )
                  end
                )
              )
            ),
            t(:ul, {className: "dropdown-menu"},
              *splat_each(state.options) do |option|
                t(:li, {style: {cursor: "pointer"}.to_n, onClick: ->{select(option)}}, " ", 
                  option.show_value
                )
              end
            )
          )
        else
          t(:div, {}, "fooo")
        end
      end

      def toggle_dropdown
        set_state open: !state.open
      end

      def select(option)
        selected = state.options.delete(option)
        state.selected << selected
        set_state selected: state.selected, options: state.options
      end

      def deselect(option)
        deselected = state.selected.delete(option)
        state.options << deselected
        set_state selected: state.selected, options: state.options
      end

      def collect
        x = state.selected
        selected = []
        state.selected.each do |opt|
          selected << opt.value
        end
        props.model.attributes[props.attr] = selected
      end


    end
  end
end