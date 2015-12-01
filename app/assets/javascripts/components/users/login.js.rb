module Users

  class Login < RW

    expose
    include Plugins::Formable

    def init
      @controller = UsersController.new(self)
    end

    def initial_state
      {
        form_model: CurrentUser.new,
        message: []
      }
    end

    def render
      t(:div, {className: "login_form"},
        *splat_each(state.message) do |m|
          t(:h3, {}, m)
        end,
        input(Forms::Input, state.form_model, :email, {}),
        input(Forms::Input, state.form_model, :password, {type: "password"}),
        t(:br, {} ),
        t(:button, {onClick: ->(){controller.login}}, "login"),
        t(:br, {}),
        link_to("Forgot your password? press here to restore", "/users/password_reset")
      )
    end

  end

end