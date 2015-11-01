module Shared
	class Modal < RW
    expose_as_native_component

    def initial_state
      {
        display: "none"
      }
    end

    def init
      @head = t(:p, {})
      @content = t(:div, {})
    end

		def render
			t(:div, {className: "modal", style: {display: state.display}},
				t(:div, {className: "modal-dialog", role: "document"},
					t(:div, {className: "modal-content"},
						t(:div, {className: "modal-header"},
              t(:button,{className: "close", onClick: ->(){close}}, "x"),
              @head
            ),
            t(:div, {className: "modal-body"},
              @content,      
              children
            )
					)					
				)
			)
		end

		def open(head_content = false, content = false)
      @head = head_content if head_content
      @body = content if content
			Element.find("body").add_class("modal-open")
			set_state display: "block"
		end

    def close(preserve = false)
      @head = t(:p, {} ) unless preserve
      @content = t(:div, {}) unless preserve
      Element.find("body").remove_class("modal-open")
      set_state display: "none"
    end

	end
end
