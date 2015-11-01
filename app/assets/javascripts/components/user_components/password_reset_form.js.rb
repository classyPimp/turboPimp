module Users
	class PasswordResetForm < RW
		
		expose_as_native_component

		def assign_controller
			@controller = UsersController.new(self)
		end
		attr_accessor :blank_errors
		def init
			@blank_errors = {password: [], password_confirmation: []}
		end
 
		def initial_state
			{
				message: false,
				errors: @blank_errors,
				inputs: {password: "", password_confirmation: ""},
				email: props.location.query.email,
				id: props.params.digest
			}

		end

		def render
			t(:div, {},
				spinner,
				if state.message
					t(:p, {}, state.message)
				end,
				t(:p, {}, "enter new password"),
        *if (e = self.state.errors[:password])
          (splat_each(e) do |er|
            t(:p, {}, er)
          end)
        end,
        t(:input, {type: "password", ref: "password_input", defaultValue: state.inputs[:password]}),
        t(:br, {} ),
        t(:p, {}, "confirm new password"),
        if state.errors[:password_confirmation]
          t(:p, {}, state.errors[:password_confirmation])
        end,
        t(:input, {type: "password", ref: "password_confirmation_input"}),
        t(:br, {} ),
        t(:button, {onClick: ->(){@controller.update_new_password}}, "update password")
			)
		end

		def send_password_reset_email
			@controller.send_password_reset_email
		end


	end
end