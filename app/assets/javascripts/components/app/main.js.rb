module Components
  module App
    class Main < RW
      
      expose

      class << self
        attr_accessor :instance
        attr_accessor :props_from_server
        attr_accessor :history
        attr_accessor :view_port_kind
        attr_accessor :location
        
      end

      def self.set_view_ports_size  
        @screen_width = Element.find(`window`).width()
        screen_type = 'lg_device'
        if @screen_width <= 480
          screen_type = 'xs_device'
        elsif @screen_width <= 768
          screen_type = 'sm_device'
        elsif @screen_width <= 1200
          screen_type = 'lg_device'
        end
        p "#{@screen_width} -- #{screen_type}"
        $VIEW_PORT_KIND = @view_port_kind = screen_type          
      end

      def init
        self.class.set_view_ports_size
        self.class.instance = self
        self.class.location = props.location
        
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
        {
          view_port_kind: self.class.view_port_kind
        }
      end

      def assign_controller
        @controller = AppController.new(self)
      end
      
      def render
        t(:div, {},
          t(Components::Menues::Index, {ref: "menu"}),
          t(Shared::Flash::Holder, {ref: "flash"}),
          spinner,
          t(:div, {className: 'below_menu'},
            t(:div, {className: 'content'}, 
              children
            ),
            unless props.location.pathname == '/'
              t(Shared::Footer, {})  
            end
          ),
          if !CurrentUser.user_instance.attributes[:registered]
            t(Components::ChatMessages::Index, {})
          end,
          modal
        )
      end

      def component_did_mount 
        handle_resizing
      end

      def handle_resizing
        Element.find(`window`).on 'resize', on_window_resize
      end

      def on_window_resize
        -> {
          self.class.set_view_ports_size
          if self.class.view_port_kind != state.view_port_kind
            set_state view_port_kind: self.class.view_port_kind
          end
        }
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


