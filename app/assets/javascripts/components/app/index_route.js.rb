module Components
  module App
    class IndexRoute < RW

      expose

      def init
        Services::MetaTagsController.new()
      end
      
      def render
        t(:div, {},
          t(Components::SpecificPages::Home, {})
        )
      end

    end
  end
end