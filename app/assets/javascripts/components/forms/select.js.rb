module Forms
  class Select < RW
    expose

    #PROPS
    #multiple: boolean #multiple select or not
    #options: [*String] #options that be given to select
    #load_from_server: Hash{url*required: <String "urld from where options be fetched">, extra_params: <Hash defaults to nil>}

    def get_initial_state
      options = props.options ? ( props.options.each.map(){|v| SelectOption.new(v) } ) : []
      multiple = props.multiple ? [] : ""
      @props_to_select = (multiple == "") ? {nil => nil} : {multiple: true}
      {
        options: options,
        selected: multiple
      }
    end  

    def component_did_mount
      if x = props.load_from_server
        HTTP.post(x[:url], payload: x[:extra_params]).then do |response|
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
        t(:select, {value: state.selected, onChange: ->(e){select(Native(e))}, ref: "#{self}"}.merge(@props_to_select),
          t(:option, {value: ""}, ""),
          *splat_each(state.options) do |v|
            t(:option, { value: "#{v}" }, v.value)
          end,
        )     
      )   
    end

    def select(e)
      if props.multiple
        x = e.target.options
        to_select = []
        (0...x.length).each do |i|
          if x[i].selected
            to_select << x[i].value
          end
        end
      else
        to_select = ref("#{self}").value
      end
      set_state selected: to_select
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