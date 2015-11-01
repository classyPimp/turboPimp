module Users
	class PasswordReset < RW

		expose_as_native_component

		def initial_state
			{
				message: false,
				errors: [],
				inputs: {email: ""}
			}

		end

		def assign_controller
			@controller = UsersController.new(self)
		end

		def render
			t(:div, {},
				spinner,
				*splat_each(state.errors) do |er|
					t(:p, {}, er) if er
				end,
				if state.message
					t(:p, {}, state.message)
				end,
				t(:p, {}, "eneter email"),
				t(:br, {}),
				t(:input, {type: "email", ref: "email_input", defaultValue: state.inputs[:email]}),    
				t(:p, {}, "pressing the link below will send you an email containing password reset instructions"),
				t(:button, {onClick: ->(){send_password_reset_email}}, "send me instructions")
			)
		end

		def send_password_reset_email
			@controller.send_password_reset_email
		end

	end
end