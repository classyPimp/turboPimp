require "controllers/users_controller"

module UserComponents

  class SignUp < RW

    attr_accessor :blank_errors

    def init
      @controller = UsersController.new(self)
    end

    def blank_errors
      {
        email: [],
        password: [],
        password_confirmation: []
      }
    end

    def initial_state
      {
        user: User.new,
        errors: blank_errors,
        inputs: {},
        loading: false,
        submitted: false
      }
    end

    def render
      t(:div, {className: "create_user_form"},
        if state.loading
          t(:h1, {}, "Loading")
        end,
        if state.submitted
          t(:h1, {}, "Confirmation letter was sent to #{self.state.inputs[:email]}")
        end,
        t(:p, {}, "enter email"),
        *if (e = self.state.errors[:email])
          (splat_each(e) do |er|
            t(:p, {}, er)
          end)
        end,
        t(:input, {type: "email", ref: "email_input", defaultValue: state.inputs[:email]}),
        t(:br, {} ),
        t(:p, {}, "enter password"),
        *if (e = self.state.errors[:password])
          (splat_each(e) do |er|
            t(:p, {}, er)
          end)
        end,
        t(:input, {type: "password", ref: "password_input", defaultValue: state.inputs[:password]}),
        t(:br, {} ),
        t(:p, {}, "confirm password"),
        if state.errors[:password_confirmation]
          t(:p, {}, state.errors[:password_confirmation])
        end,
        t(:input, {type: "password", ref: "password_confirmation_input"}),
        t(:br, {} ),
        t(:br, {} ),
        t(:button, {onClick: controller.submit_form}, "create new user")
      )
    end

  end
end
