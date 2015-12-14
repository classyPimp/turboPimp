module Forms
  class Select < RW
    expose
    
    #PROPS
    #multiple: boolean #multiple select or not
    #options: [*String] #options that be given to select
    #load_from_server: Hash{url*required: <String "urld from where options be fetched">, extra_params: <Hash defaults to nil>}
    #attr: from_model of parent @attributes to populate with this input on collect

    def get_initial_state 
      {
        selected: props.model
        options: props.options
        mark_for_destruction: props.mark_for_destruction
      }

    end  

    def component_did_mount
      if x = props.load_from_server
        Role.index({}, {to_fetch: "general"}).then do |roles|
          options = Model.parse(roles)
          set_state options: options
        end
      end
    end

    def render
      t(:div, {},

        *props.model do |role|          
          t(:span, {className: "label label-default", ref: "#{role}"}, role.name, " x")
        end

        t(:select, {onChange: ->(e){select(Native(e))}, ref: "#{self}"},
          t(:option, {value: ""}, ""),
          *splat_each(state.options) do |v|
            t(:option, { value: "#{v}" }, v.name)
          end,
        )     
      )   
    end

    def select(e)
      to_select = ref("#{self}").value
    end

    def collect
      state.selected.each do |role|
        Role.new(name: role)
      end
      props.model.attributes[props.attr.to_sym] = 
    end

    def clear_inputs
      state.options.each do |opt|
        opt.selected = false
      end
    end

  end

  class SelectOption
    
    attr_accessor :value

    def initialize(value)
      @value = value
    end

  end
end