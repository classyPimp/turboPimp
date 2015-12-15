module Forms
  class Select < RW
    expose

    #input(Forms::MultipleSelect, user, :roles, {serialize_value: {model_name: :role, value_attr: :name}})



    def get_initial_state
      @options = ["foo", "bar", "baz"]
      @options_map = {}

      @options.each do |val|
        x = SelectOption.new val
        @options_map["#{x}"] = x
      end
      p @options_map
      {}
    end

    def render
      t(:div, {}, 
        t(:select, {onChange: ->{handle}, ref: "select" }, 
          *splat_each(@options_map) do |k, v|
            t(:option, {value: k}, v.value_to_show)
          end
        )
      )
    end

    def handle
      x = ref("select").value
      p @options_map[x].data
    end

  end

  class SelectOption
    
    attr_accessor :value_to_show, :data

    def initialize(data, value_attr = false)
      
      @data = data

      if @data.is_a? String
        @value_to_show = @data 
      end

    end

  end
end

