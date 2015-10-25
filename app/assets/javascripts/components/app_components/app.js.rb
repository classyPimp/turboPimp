class About < Bar
  
  expose_as_native_component

  def init
    @ar = [1] * 100
    @val = "fooz"
  end

  def initial_state
    {
      foo: "foo"
    }
  end

  def render
    t(:div, {},
      "ABOUT PAGE",
      t(:p, {}, "UPDATE"),
      t(Mock, {}, 
        t(MockS, {})
      ),
      children
    )
  end

  def upd
    set_state foo: "bar"
  end

  def component_will_unmount
    p "unmount #{self}"
  end

  def component_will_update
    p "will update #{self}"
  end

  def handle
    
  end
end

class Mock < Bar
  expose_as_native_component
  def render
    t(:div, {}, 
      t(:p, {onClick: ->(){set_state foo: "bar"}}, "update"),
      t(`MockS`, {key: "foo"}, "mocks")
    )
  end

  def should_component_update?(next_props, next_state)
    p "shoold? #{self}"
  end

  def component_will_unmount
    p "unmount #{self} #{props.mock}"
  end

  def component_will_update
    p "will update #{self} #{props.mock}"
  end
end

class MockS < Bar

  expose_as_native_component

  def render
    t(:div, {}, 
      "SubMOICK"
    )
  end

  def should_component_update?(next_props, next_state)
    p "shoold #{self}?"

  end

  def component_will_unmount
    p "unmount #{self} #{props.mock}"
  end

  def component_will_update
    p "will update #{self} #{props.mock}"
  end
end


class App < Bar

  expose_as_native_component
 
  def render
    t(:div, {onClick: ->(){handler}},
      t(:div, {},
        t(:p, {}, 
          t(`Link`, {to: "/about"}, 
            "about"
          ),
          t(:br, {}, nil),
          t(`Link`, {to: "/home"},
            "home"
          ),
          t(:br,{}, nil),
          t(`Link`, {to: "/home/depot"},
            "home depot!"
          ),
          t(:br, {}, nil),
          t(`Link`, {to: "/users/new"}, 
            "create new user"
          ),
          t(:br,{})
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

class Depot < Bar

  expose_as_native_component

  def render
    t(:div, {},
      "This is DEPOT"
    )

    
  end

end


class Home < Bar
  expose_as_native_component  

  def render
    t(:div, {},
      t(:p,{},
        "some::HOME"
      ),
      children

    )
  end
end 



class Routie < Bar

  expose_as_native_component

  def init
    @controller = AppController.new(self)
  end

  def render
    t(`Router`, {history: Native(`History()`)},
      t(`Route`, {path: "/", component: App.create_class},
        t(`Route`, {path: "/about", component: About.create_class}),
        t(`Route`, {path: "/home", component: Home.create_class},
          t(`Route`, {path: "depot", component: Depot.create_class},
          )
        ),
        t(`Route`, {path: "/users", component: UserComponents::Main.create_class}, 
          t(`Route`, {path: "new", component: UserComponents::CreateUser.create_class },
          ),
          t(`Route`, {path: "activations", component: UserComponents::Activations.create_class},
          ),
          t(`Route`, {path: ":id", component: UserComponents::Show.create_class})
        )
      )
    )
  end

end

`window["Routie"] = #{Routie.create_class}`




