module Components
  module Menues
    class Index < RW
      expose

      def initial_state
        {
          menu: false
        }
      end

      def component_did_mount
        p "WHAT UP!"
        menu = MenuItem.index.then do |_menu|
          p _menu
          #set_state menu: _menu
        end
      end

      def render
        t(:div, {onClick: ->(){save}}, "foo")
      end

      def save
        
      end
    end
  end
end