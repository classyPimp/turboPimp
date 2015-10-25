class About < RW
  
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

class Mock < RW
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

class MockS < RW

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


class App < RW

  expose_as_native_component

  def component_will_update
    p "app updated"
  end
 
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

class Depot < RW

  expose_as_native_component

  def render
    t(:div, {},
      "This is DEPOT"
    )

    
  end

end


class Home < RW
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










