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
          registered = !!x.user.registered
          x = `JSON.stringify(#{x.to_n})`
          x = CurrentUser.user_instance = Model.parse(x)
          x.attributes[:registered] = "true" if registered
          if CurrentUser.user_instance.attributes[:registered]
            CurrentUser.logged_in = true
          end
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
          t(Components::ChatMessages::Index, {}),
          modal
        )
      end

      #flash message example
      #msg = Shared::Flash::Message.new( t(:button, {onClick: ->{self.x}}, "PRREASS ME"), "success")
      #Components::App::Main.instance.ref(:flash).rb.add_message(msg)
      #
      #modal example
      #def modal_handler 
      #  ref(:modal).rb.open(t(:p, {}, "THE HEADER"))
      #end
    end
    
  end
end


