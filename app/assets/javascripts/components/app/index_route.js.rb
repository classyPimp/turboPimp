module Components
  module App
    class IndexRoute < RW

      expose
      
      def render
        t(:div, {},
          t(Components::SpecificPages::Home, {})
        )
      end

    end
  end
end