module Forms
	class WysiTextarea < RW
		expose

		def __component_will_update__
      ref("#{self}").value = "" if props.reset_value == true
      super
    end

    def get_initial_state
      {
        html: false
      }
    end

    def valid_or_not?
      if props.model.errors[:attr]
        "invalid"
      else 
        "valid"
      end
    end

		def render
      @head_content_if_link = t(:p, {}, "choose link")
      @content_if_link = 
          t(:div, {}, 
            t(:p, {}, "link"), 
            t(:input, {type: "text", ref: "insert_link_value"}),
            t(:button, {onClick: ->(){insert_link}}, "insert link")
          )

      @head_if_image = t(:p, {}, "choose image")
      @content_if_image =
          t(:div, {},
            t(Components::Images::Index, {request_on_mount: false, should_expose: {proc: ->(image){insert_image(image)}, button_value: "Copy link"}})
          )
      @content_if_react_link =
          t(:div, {}, 
            t(:p, {}, "link"), 
            t(:input, {type: "text", ref: "insert_link_value"}),
            t(:button, {onClick: ->(){insert_react_link}}, "insert link")
          )

			t(:div, {className: 'wysi_textarea'},
        t(Shared::Modal, {ref: "modal"}),
        t(:p, {}, props.show_name),
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
				t(:div, {id: "wysi_toolbar", style: {display: "none"}.to_n},
					t(:button, {className: 'btn btn-xs', "data-wysihtml5-command" => "bold"}, "BOLD"),
					t(:button, {onClick: ->{set_state html: !state.html},className: 'btn btn-xs', "data-wysihtml5-action" => "change_view", "unselectable"=>"on"},
						if state.html
              "switch to non html"
            else
              'switch to html'
            end
					),
          t(:button, {className: 'btn btn-xs', onClick: ->{ open_modal_for_react_link } }, 'create react link'),
          t(:button, {className: 'btn btn-xs', onClick: ->(){open_modal_for_link}}, "insert link"),
          t(:button, {className: 'btn btn-xs', onClick: ->(){open_modal_for_image}}, "insert image")
				),
				t(:textarea, {className: "form-control", rows: "30", id: "wysi", defaultValue: props.model.attributes[props.attr]})
			)
		end

		def component_will_unmount
			@wysi_editor.destroy
		end

    def open_modal_for_link
      ref(:modal).rb.open(@head_content_if_link, @content_if_link)
    end

    def open_modal_for_image
      ref(:modal).rb.open(@head_if_image, @content_if_image)
    end

    def open_modal_for_react_link
      ref(:modal).rb.open(@head_content_if_link, @content_if_react_link)
    end

    def insert_link
      link = ref("insert_link_value").value
      @wysi_editor.composer.commands.exec("createLink", { href: link})
      ref(:modal).rb.close
    end

    def insert_image(image)
      @wysi_editor.composer.commands.exec("insertImage", { src: image.url, alt: image.alt })
      ref(:modal).rb.close
    end

    def insert_react_link
      text = `#{@wysi_editor.to_n}.composer.selection.getHtml()`
      link = ref('insert_link_value').value
      if text
        @wysi_editor.composer.commands.exec("insertHTML", "<a class='react_link' href=#{link}>#{text}</a>")
      end
    end

		def component_did_mount
			@wysi_editor = Native(%x{
				new wysihtml5.Editor("wysi", { 
				  toolbar: "wysi_toolbar",
          parserRules:    wysihtml5ParserRules
				})
			})
		end

    def collect
      props.model.attributes[props.attr.to_sym] = @wysi_editor.getValue
    end

	end
end

