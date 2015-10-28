class App < RW

  expose_as_native_component

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
 
  def render
    t(:div, {onClick: ->(){handler}},
      if false
        "false"
      end,
      t(UserComponents::LoginInfo, {}),
      t(:div, {},
        t(:p, {}, 
          t(`Link`, {to: "/login"}, 
            "login"
          ),
          t(:br, {}),
          t(`Link`, {to: "/users/new"}, 
            "create new user"
          ),
          t(:br,{}),
          link_to("the dummy component", "/test")
        )
      ),
      t(:div, {},
        children
      )
    )
  end

  def handler
    
  end
end





