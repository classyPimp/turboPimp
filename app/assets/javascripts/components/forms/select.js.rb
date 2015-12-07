module Forms
  class Select < RW
    expose

    def get_initial_state
      options = props.options ? ( props.options.each.map(){|v| SelectOption.new(v) } ) : []
      multiple = props.multiple ? [] : ""
      {
        options: options,
        selected: multiple
      }
    end

    def component_did_mount
      if x = props.load_from_server
        HTTP.get(x[:url], data: x[:extra_params]).then do |response|
          options = response.json[:options].each.map(){|v| SelectOption.new(v) }
          set_state options: options
        end
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
        t(:select, {value: state.selected},
          *splat_each(state.options) do |v|
            t(:option, { onClick: ->(){alert("foo")}, value: "#{v}" }, v.value)
          end
        )     
      )   
    end

    def select(s_o)
      unless props.multiple
        state.selected == "#{s_o}" ? "#{s_o}" : ""
      else
        
      end
      
      set_state options: state.options
    end

    def collect
      props.model.attributes[props.attr.to_sym] = state.selected
    end

    def clear_inputs
      state.options.each do |opt|
        opt.selected = false
      end
    end

  end

  class SelectOption
    
    attr_accessor :value, :selected

    def initialize(value, selected = false)
      @value = value
      @selected = selected
    end

    def selected!
      @selected = !@selected
    end

  end
end