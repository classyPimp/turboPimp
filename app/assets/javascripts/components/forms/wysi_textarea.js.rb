module Forms
	class WysiTextarea < RW
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
				t(:div, {id: "wysi_toolbar", style: {display: "none"}},
					t(:a, {"data-wysihtml5-command" => "bold"}, "BOLD"),
					t(:a, {"data-wysihtml5-action" => "change_view", "unselectable"=>"on"},
						"switch to html"
					)
				),
				t(:textarea, {className: "form-control", rows: "5", id: "wysi", defaultValue: props.model.attributes[props.attr]})
			)
		end

		def component_will_unmount
			@wysi_editor.destroy
		end

		def component_did_mount
			@wysi_editor = Native(%x{
				new wysihtml5.Editor("wysi", { 
				  toolbar:      "wysi_toolbar",
				  parserRules:  wysihtml5ParserRules
				})
			})
		end

    def collect
      props.model.attributes[props.attr.to_sym] = @wysi_editor.getValue
    end


	end
end

