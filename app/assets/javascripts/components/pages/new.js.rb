module Components  
  module Pages
    class New < RW
      expose 

      include Plugins::Formable

      def assign_controller
        @controller = PagesController.new(self)
      end

      def get_initial_state
        {
          form_model: Page.new
        }
      end

      def render
        t(:div, {},
          if state.page_saved
            t(:div, {},
              t(:p, {}, "page have been successfully saved, you can:"),
              link_to("go to pages index", "/pages/index"),
              t(:a, {onClick: ->(){@controller.restart_new}}, "or create one more")
            )
          else
            t(:div, {}, 
              input(Forms::Input, state.form_model, :title, {type: "text", show_name: 'title'}),
              input(Forms::Input, state.form_model, :m_title, {type: "text", show_name: 'meta title'}),
              input(Forms::Input, state.form_model, :m_description, {type: "text", show_name: "meta description"}),
              input(Forms::Input, state.form_model, :m_keywords, {type: "text", show_name: 'meta keywords'}),
              input(Forms::WysiTextarea, state.form_model, :body),
              t(:button, {onClick: ->(){@controller.handle_inputs_for_new}}, "create page")
            )
          end
        )
      end

    end
  end
end