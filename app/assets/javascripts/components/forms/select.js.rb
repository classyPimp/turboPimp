module Forms
  class Select < RW
    expose

    # PROPS
    # 
    # optional multiple: bool => as expected
    # required options: array of strings || required server_feed: {url: String url to feed from (post req be made), extra_params: hash for payload}
    
    # select model, :name, {s_value: "id", s_show: "name"} => feed: [{name: "foo", id: "bar"}] -> select "name"
    # select model, :roles, {s_value: "name", option_as_model: :role} => feed: ["foo", "bar"]
    # select model, user, {s_value: "name", s_show: "id", :feed_as_model}
    #

    def init
      @loaded = true
      server_feed?
      @multiple = props.multiple ? true : false
      #props.model.attributes[props.attr] = props.model.attributes[props.attr]
      #@attr_as_model = (x = props.attr_as_model) ? x : false
      @option_as_model = (x = props.option_as_model) ? x : false
      @s_value = (x = props.s_value) ? x : false
      @s_show = (x = props.s_show) ? x : @s_value
      prepare_all
    end

    def prepare_all
      @options ||= props.options || []
      @selected = []

      if @option_as_model && !@options[0].is_a?(Model)
        @options.map! do |option|
          Model.parse(option)
        end
      end    

      if @multiple

        unless props.model.attributes[props.attr] == nil
          props.model.attributes[props.attr].each do |pre_selected|
            handle_preselected(pre_selected)
          end
        end

      else

        pre_selected = props.model.attributes[props.attr]
        handle_preselected(pre_selected) if pre_selected

      end
   
    end

    def handle_preselected(pre_selected)
      if @option_as_model
        pre_selected.arbitrary[:initially_selected] = true
        @options.delete_if do |option|
          pre_selected.attributes[@s_value] == option.attributes[@s_value]
        end
      elsif @s_show != @s_value && !@option_as_model 
        @options.delete_if do |option|
          if "#{option[@s_value]}" == "#{props.model.attributes[props.attr]}"
            pre_selected = option
          end 
        end
      else
        @options.delete_if do |option|
          option == props.model.attributes[props.attr]
        end
      end
      @selected << pre_selected
    end

    def server_feed?
      @loaded = false
      if s_f = props.server_feed
        @options = []
        HTTP.post(s_f[:url], payload: s_f[:extra_params]).then do |response|
          @options = response.json
          prepare_all
          @loaded = true
          set_state options: @options, selected: @selected
        end
      end
    end

    def get_initial_state
      {
        open: false,
        options: @options,
        selected: @selected
      }
    end

    def combined_errors
      x = props.model.errors[props.attr].clone
      y = props.model.errors[props.show_errors_for].clone
      x = (x.is_a? Array) ? x : [] #for some reason ||= didn't work for Opal in this situation
      y = (y.is_a? Array) ? y : []
      x + y      
    end

    def render
      if @loaded
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
                  t(:span, {className: "label label-default", style: {cursor: "pointer"}.to_n, onClick: ->{delete(selected)}},
                    if selected.is_a? Model
                      next if selected.attributes[:_destroy]
                      "#{selected.attributes[@s_value]} X"
                    elsif @s_value != @s_show
                      "#{selected[@s_show]} X"
                    else
                      selected
                    end        
                  )
                end
              )
            )
          ),
          t(:ul, {className: "dropdown-menu"},
            *splat_each(state.options) do |option|
              t(:li, {style: {cursor: "pointer"}.to_n, onClick: ->{select(option)}}, " ", 
                if option.is_a? Model
                  option.attributes[@s_value]
                elsif @s_value != @s_show
                  option[@s_show]
                else
                  option
                end
              )
            end
          )
        )
      else
        t(:div, {})
      end
    end

    def delete(selected)
      if @option_as_model && props.destroy == false
        if selected.arbitrary[:initially_selected]
          selected.attributes[:_destroy] = "1"
          state.options << selected
        else
          state.options << state.selected.delete(selected)
        end
      else
        state.options << state.selected.delete(selected)
      end
      set_state options: state.options
    end

    def select(option)
      if @multiple
        if @option_as_model
          if option.arbitrary[:initially_selected] && option.attributes[:_destroy] == "1"
            state.options.delete(option)
            option.attributes.delete(:_destroy)
          else
            state.selected << state.options.delete(option)
          end
        else
          state.selected << state.options.delete(option)
        end
      else
        if @option_as_model && state.selected[0]
          if state.selected[0].arbitrary[:initially_selected]
            state.selected[0].attributes[:_destroy] = "1"
          end
        end
        state.open = false
        state.options << state.selected[0] if state.selected[0]
        state.selected[0] = state.options.delete(option)
      end
      set_state selected: state.selected
    end

    def toggle_dropdown
      set_state open: !state.open
    end

    def collect
      if state.selected[0].is_a? Model
        props.model.attributes[props.attr] = @multiple ? state.selected : state.selected[0]
      else
        selected = []
        state.selected.each do |sel|
          selected << sel[@s_value]
        end
        props.model.attributes[props.attr] = @multiple ? selected : selected[0]
      end
    end
  end
end