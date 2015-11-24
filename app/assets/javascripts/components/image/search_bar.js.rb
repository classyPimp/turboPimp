module Components
  module Images
    class SearchBar < RW
      expose

      def initial_state
        {
          form_model: Image.new
        }
      end

      def render
        t(:div, {},
          t(:p, {}, "search for image"), 
          t(Forms::Input, state.form_model, :alt, {type: "text"}),
          t(Forms::Input, state.form_model, :search_query, {type: "text"}), 
          t(:button, {onClick: ->(){search_for_image}}, "search")
        )
      end

      def search_for_image
        props.search_for_image(state.form_model)
      end
    end
  end
end

{onSearch: ->(img){perform_search(img)}}

