module Users
  class PasswordResetForm < RW
    
    expose_as_native_component
    include Plugins::Formable

    def assign_controller
      @controller = UsersController.new(self)
    end
    attr_accessor :blank_errors
 
    def initial_state
      user = User.new
      {
        message: false,
        form_model: user,
        id: props.params.digest,
        email: props.location.query.email
      }

    end

    def render
      t(:div, {},
        spinner,
        if state.message
          t(:p, {}, state.message)
        end,
        input(Forms::Input, state.form_model, :password, {type: "password"}),
        input(Forms::Input, state.form_model, :password_confirmation, {type: "password"}),
        t(:br, {} ),
        t(:button, {onClick: ->(){@controller.update_new_password}}, "update password")
      )
    end

  end
end