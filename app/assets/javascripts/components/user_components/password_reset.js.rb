module Users
  class PasswordReset < RW

    expose_as_native_component
    include Plugins::Formable

    def initial_state
      {
        message: false,
        form_model: User.new
      }

    end

    def assign_controller
      @controller = UsersController.new(self)
    end

    def render
      t(:div, {},
        spinner,
        if state.message
          t(:p, {}, state.message)
        end,
        input(Forms::Input, state.form_model, :email, {}),
        t(:p, {}, "pressing the link below will send you an email containing password reset instructions"),
        t(:button, {onClick: ->(){@controller.send_password_reset_email}}, "send me instructions")
      )
    end

  end
end