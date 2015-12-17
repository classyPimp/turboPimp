module Forms
  class SingleSelect < RW
    expose

    #input(Forms::SingleSelect, user, :roles, {serialize_value: {model_name: :role, value_attr: :name}})
    # PROPS
    # serialize_value: {required model_name: string, required value_attr: string, optional mark_for_destruction: bool} 
    #   passing this prop will: options will be serialized to model_name: {value_attr: value} as well this option will infer that\
    #   currently selected value is model if it is. value_attr will be show
    # options: [*string], if serialize_value prop was given will serialize to provided model, else will be treated as string.
    #   the value in array will be options
    # allow_blank: bool , if true will include "" option
    # server_feed: {url: string (will make a post request here), extra_params: extra_params(will be passed to HTTP request)}


              # DEPRECATED
              # leaving it be in case will need html select

    def init
      server_feed
      prepare_all       
    end

    def prepare_all
      @options ||= props.options || []
      if props.allow_blank
        @options << ""
      end
      @options_map = {}
      @model_attribute = props.model.attributes[props.attr]
      prepare_selected
      map_options
    end

    def get_initial_state
      {
        options_map: @options_map,
        selected: @selected
      }
    end

    def server_feed
      if s_f = props.server_feed
        @options = []
        HTTP.post(s_f[:url], payload: s_f[:extra_params]).then do |response|
          @options = response.json
          prepare_all
          state.options_map = @options_map
          set_state selected: @selected
        end
      end
    end

    def prepare_selected
      
      @selected = props.model.attributes[props.attr]

    end

    def map_options

      if s_v = props.serialize_value

        if @selected.is_a? Model
          @initially_selected_model = @selected
          selected_val = @selected.attributes[s_v[:value_attr]]

          @options.each do |option|
            
            if option == selected_val

              s_v[:initially_selected] = true
              s_o = SelectOption.new @selected, s_v
              @selected = "#{s_o}"
              selected_val = false
              s_v[:initially_selected] = false

            else
              s_o = SelectOption.new option, s_v
            end

            @options_map["#{s_o}"] = s_o

          end

        end

      else

        selected_val = @selected


        @options.each do |option|
          
          if option == selected_val

            s_o = SelectOption.new option, {initially_selected: true}
            @selected = "#{s_o}"

          else

            s_o = SelectOption.new option

          end 

          @options_map["#{s_o}"] = s_o

        end

      end
        
    end

    def render
      t(:div, {}, 
        t(:select, {onChange: ->{handle}, ref: "select", value: state.selected },
          *splat_each(@options_map) do |k, v|
            t(:option, {value: k}, v.show_value)
          end
        )
      )
    end

    def handle
      @selected = ref("select").value
      set_state selected: @selected 
    end

    def collect
      if props.serialize_value[:mark_for_destruction]
        if @options_map[@selected] != @initially_selected_model
          @initially_selected_model.attributes[:_destroy] = "1"
        end
      end

      props.model.attributes[props.attr] = @options_map[@selected].data

    end

  end

  class SelectOption
    
    attr_accessor :show_value, :data, :initially_selected

    def initialize(data, options = {})
      
      @data = data

      @options = options

      prepare

    end

    def prepare
      if_string
      if_model
    end

    def if_string

      if @data.is_a?(String) && !@options[:model_name]

        @show_value = (s_v = @options[:show_value]) ? s_v : @data  

      end

    end

    def if_model
      
      if @data == ""
        
        @show_value = @data

      elsif @options[:model_name] && @data.is_a?(String)

        @show_value = @data
        @initially_selected = true if @options[:initially_selected]
        @data = Model.parse({@options[:model_name] => {@options[:value_attr] => @data} })

      elsif @options[:model_name] && @data.is_a?(Model)

        @initially_selected = true if @options[:initially_selected]
        @show_value = @data.attributes[@options[:value_attr]]

      end
    end

  end
end

