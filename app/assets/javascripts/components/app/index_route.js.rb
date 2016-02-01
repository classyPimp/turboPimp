module Components
  module App
    class IndexRoute < RW

      expose
      
      def render
        t(:div, {},
          t(Components::SpecificPages::Home, {}),
          t(Components::ChatMessages::Index, {})
        )
      end

    end
  end
end