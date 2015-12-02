module Components
  module Images
    class SearchBar < RW
      expose

      include Plugins::Formable

      def initial_state
        {
          form_model: Image.new
        }
      end

      def render
        t(:div, {},
          t(:p, {}, "search for image"), 
          input(Forms::Input, state.form_model, :search_query, {type: "text"}), 
          t(:button, {onClick: ->(){search_for_image}}, "search")
        )
      end

      def search_for_image
        collect_inputs
        props.search_for_image(state.form_model)
      end
    end
  end
end


