class App < RW
  
  expose

  class << self
    attr_accessor :history
  end

  def init
    @controller = AppController.new(self)
  end

  def component_did_mount
    self.class.history = props.history
    AppController.check_credentials
  end

  def component_will_update
    AppController.check_credentials
  end
  
  def component_will_unmount
    p "#{self} gon unmount!"
  end


  def render
    t(:div, {},
      if false
        "false"
      end,
      t(Users::LoginInfo, {}),
      t(:div, {},
        t(:p, {}, 
          link_to("login", "/users/login"),
          t(:br, {}),
          link_to("signup", "/users/signup"),
          t(:br, {}),
          link_to("test", "/test"),
          t(:br, {}),
          link_to("new page", "/pages/new"),
          t(:br, {}),
          link_to("page index", "/pages/index")
        ),
        spinner
      ),
      t(:div, {},
        children
      ),
      modal({},
        t(:p, {}, "WHAT UP DOWGS")
      )
    )
  end

  def modal_handler 
    ref(:modal).__opalInstance.open(t(:p, {}, "THE HEADER"))
  end
end

