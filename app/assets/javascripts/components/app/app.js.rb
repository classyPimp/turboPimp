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
  end

  def component_will_update
    AppController.check_credentials
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

  def modal_handler 
    ref(:modal).__opalInstance.open(t(:p, {}, "THE HEADER"))
  end
end

