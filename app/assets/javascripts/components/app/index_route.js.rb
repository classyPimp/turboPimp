module Components
  module App
    class IndexRoute < RW

      expose

      def component_will_mount
        set_up_phantom_yielder(3)
      end
      
      def render
        t(:div, {},
          t(Components::SpecificPages::Home, {})
        )
      end

    end
  end
end