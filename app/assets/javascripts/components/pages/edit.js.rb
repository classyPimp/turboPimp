module Components
  module Pages
    class Edit < RW
      expose

      include Plugins::Formable

      def assign_controller
        @controller = PagesController.new(self)
      end

      def initial_state
        {
          form_model: false
        }
      end

      def component_did_mount
        Page.show({id: props.params.id}).then do |page|
          set_state form_model: page
        end.fail do |res|
          alert res
        end
      end

      def render
        t(:div, {},
          if state.page_saved
            t(:div, {},
              t(:p, {}, "page have been successfully updated, you can:"),
              link_to("go to pages index", "/pages/index"),
              t(:a, {onClick: ->(){@controller.restart_new}}, "or create one more")
            )
          else
            if state.form_model
              t(:div, {}, 
                input(Forms::Input, state.form_model, :title, {type: "text"}),
                input(Forms::Input, state.form_model, :m_title, {type: "text"}),
                input(Forms::Input, state.form_model, :m_description, {type: "text"}),
                input(Forms::Input, state.form_model, :m_keywords, {type: "text"}),
                input(Forms::WysiTextarea, state.form_model, :body),
                t(:button, {onClick: ->(){@controller.handle_inputs_for_update}}, "create page")
              )
            else
              t(:p, {}, "loading!")
            end
          end
        )
      end
    end
  end
end