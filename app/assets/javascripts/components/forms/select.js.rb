module Forms
  class Select < RW
    expose

    # input(Forms::MultipleSelect, user, :roles, {options: [], serialize_value: {model_name: :role, value_attr: :name, 
    #                                               mark_for_destruction: true, allow_blank: true}})
    # PROPS
    # optional serialize_value: {model_name: String model to serialize to, value_attr: atr on model_name holding value to be selected}
    # optional multiple: bool => as expected
    # required options: array of strings || required server_feed: {url: String url to feed from (post req be made), extra_params: hash for payload}
    

    def init
      server_feed?
      @multiple = props.multiple ? true : false
      @serialize_value = (s_v = props.serialize_value) ? s_v : false
      prepare_all
    end

    def prepare_all

      @options ||= props.options || []
      @selected = []
      @substract_from_options = []

      if @multiple

        unless props.model.attributes[props.attr] == nil
          props.model.attributes[props.attr].each do |pre_selected|
            handle_preselected(pre_selected)
          end
        end

      else

        pre_selected = props.model.attributes[props.attr]
        handle_preselected(pre_selected)

      end

      @options = @options - @substract_from_options

      if @serialize_value
        @options.map! do |option|
            Model.parse({@serialize_value[:model_name] => {@serialize_value[:value_attr] => option}})
        end
      end        
    
    end

    def handle_preselected(pre_selected)
      pre_selected.arbitrary[:initially_selected] = true if @serialize_value
      @substract_from_options << (@serialize_value ? 
                                           pre_selected.attributes[@serialize_value[:value_attr]] :
                                           pre_selected)
      @selected << pre_selected
    end

    def server_feed?
      if s_f = props.server_feed
        @options = []
        HTTP.post(s_f[:url], payload: s_f[:extra_params]).then do |response|
          @options = response.json
          prepare_all
          state.selected = @selected
          set_state options: @options
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

    def render
      t(:div, {className: "dropdown #{state.open ? "open" : ""}"},
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
                t(:span, {className: "label label-default", style: {cursor: "pointer"}, onClick: ->{delete(selected)}},
                  if @serialize_value 
                    next if selected.attributes[:_destroy]
                    "#{selected.attributes[props.serialize_value[:value_attr]]} X"
                  else
                    "#{selected} X"
                  end    
                )
              end
            )
          )
        ),
        t(:ul, {className: "dropdown-menu"},
          *splat_each(state.options) do |option|
            t(:li, {style: {cursor: "pointer"}, onClick: ->{select(option)}}, " ", 
              if @serialize_value
                option.attributes[props.serialize_value[:value_attr]]
              else
                option
              end
            )
          end
        )
      )
    end

    def delete(selected)
      if @serialize_value
        if selected.arbitrary[:initially_selected]
          selected.attributes[:_destroy] = "1"
          state.options << selected
        end
      else
        state.options << state.selected.delete(selected)
      end
      set_state options: state.options
    end

    def select(option)
      if @serialize_value
        if option.arbitrary[:initially_selected] && option.attributes[:_destroy] == "1"
          option.attributes.delete(:_destroy)
        end
      end
      if @multiple
        state.selected << state.options.delete(option)
      else
        if @serialize_value && state.selected[0]
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
      props.model.attributes[props.attr] = @multiple ? state.selected : state.selected[0]
    end
  end
end