module Components
  module App
    class Main < RW
      
      expose

      class << self
        attr_accessor :instance
        attr_accessor :props_from_server
        attr_accessor :history
      end

      def init
        self.class.instance = self
      end

      def get_initial_state  
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
          t(Components::Menues::Index, {ref: "menu"}),
          t(Shared::Flash::Holder, {ref: "flash"}),
          spinner,
          t(:div, {},
            children
          ),
          modal({},
            t(:p, {}, "WHAT UP DOWGS")
          )
        )
      end

      #flash message example
      #msg = Shared::Flash::Message.new( t(:button, {onClick: ->{self.x}}, "PRREASS ME"), "success")
      #Components::App::Main.instance.ref(:flash).rb.add_message(msg)
      #
      #modal example
      #def modal_handler 
      #  ref(:modal).__opalInstance.open(t(:p, {}, "THE HEADER"))
      #end
    end
    
  end
end
