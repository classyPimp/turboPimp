module Components
  module App
    class IndexRoute < RW

      expose
      
      def render
        t(:div, {},
          t(Components::Pages::Show, {page_id: "welcome"})
        )
      end

    end
  end
end