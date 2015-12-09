require "controllers/users_controller"

module Users

  class SignUp < RW

    include Plugins::Formable
 
    def init
      @controller = UsersController.new(self)
    end


    def get_initial_state
      {
        form_model: User.new,
        submitted: false
      }
    end

    def render
      t(:div, {className: "create_user_form"},
        spinner,
        if state.submitted
          t(:h3, {}, "Confirmation letter was sent to #{self.state.form_model.email} (NO LETTER WAS SEND USER::ACTIVATABLE == false"))
        end,
        input(Forms::Input, state.form_model, :email, {type: "email"}),
        input(Forms::Input, state.form_model, :password, {type: "password"}),
        input(Forms::Input, state.form_model, :password_confirmation, {}),
        t(:br, {} ),
        t(:button, {onClick: ->{controller.handle_signup_submit}}, "create new user")
      )
    end

  end
end
