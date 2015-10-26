module UserComponents

  class Login < RW

    expose_as_native_component

    def init
      @controller = UsersController.new(self)
    end

    def render
      t(:div, {className: "login_form"},
        t(:p, {}, "enter email"),
        t(:input, {type: "email", ref: "email_input"}),
        t(:br, {} ),
        t(:p, {}, "enter password"),
        t(:input, {type: "password", ref: "password_input"}),
        t(:br, {} ),
        t(:button, {onClick: ->(){controller.login}}, "login")
      )
    end

  end

end