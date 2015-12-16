module Forms
  class MultipleSelect < RW
    expose

    # input(Forms::MultipleSelect, user, :roles, {options: [], serialize_value: {model_name: :role, value_attr: :name, 
    #                                               mark_for_destruction: true, allow_blank: true}})
    
    

    def init
      @options = props.options || []
      @selected = []
      @substract_from_options = []


      if props.options

        if s_v = props.serialize_value

          props.model.attributes[props.attr].each do |pre_selected|

            pre_selected.arbitrary[:initially_selected] = true
            @substract_from_options << pre_selected.attributes[s_v[:value_attr]]
            @selected << pre_selected
          
          end

          @options = @options - @substract_from_options

          @options.map! do |option|
            Model.parse({s_v[:model_name] => {s_v[:value_attr] => option}})
          end

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
                        className: "btn btn-default", onClick: ->{toggle}},
              t(:span, {className: "caret"})
            )
          ),
          t(:div, {className: "form-control"},
            t(:p, {},
              *splat_each(state.selected) do |selected|
                t(:span, {className: "label label-default", style: {cursor: "pointer"}, onClick: ->{delete(selected)}},
                  selected.attributes[props.serialize_value[:value_attr]],
                  " x",
                )
              end
            )
          )
        ),
        t(:ul, {className: "dropdown-menu"},
          *splat_each(state.options) do |option|
              t(:li, {style: {cursor: "pointer"}, onClick: ->{select(option)}}, " ",option.attributes[props.serialize_value[:value_attr]])
          end
        )
      )
    end

    def delete(selected)
      if selected.arbitrary[:initially_selected]
        selected.attributes[:_destroy] = "1"
        p selected.pure_attributes
      end
      state.options << state.selected.delete(selected)
      set_state options: state.options
    end

    def select(option)
      if option.arbitrary[:initially_selected] && option.attributes[:_destroy] == "1"
        option.attributes.delete(:_destroy)
        p option.pure_attributes
      end
      state.selected << state.options.delete(option)
      set_state selected: state.selected
    end

    def toggle
      set_state open: !state.open
    end

  end
end