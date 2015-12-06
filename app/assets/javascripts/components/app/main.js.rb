module Components
  module App
    class Main < RW
      
      expose

      class << self
        attr_accessor :history
        attr_accessor :props_from_server
      end

      def initial_state  
        if x = self.class.props_from_server.current_user
          p Hash.new(x.to_n)
          CurrentUser.user_instance = Model.parse(Hash.new(x.to_n))
          CurrentUser.logged_in = true
        end
        {}
      end

      def assign_controller
        @controller = AppController.new(self)
      end
      
      def render
        t(:div, {},
          t(Components::Menues::Index, {}),
          spinner,
          t(:div, {},
            children
          ),
          modal({},
            t(:p, {}, "WHAT UP DOWGS")
          )
        )
      end

      #modal example
      #def modal_handler 
      #  ref(:modal).__opalInstance.open(t(:p, {}, "THE HEADER"))
      #end
    end
    
  end
end
