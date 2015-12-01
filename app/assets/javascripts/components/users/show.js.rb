module Users

	class Show < RW
		
    def initial_state
      {
        user: false
      }
    end

		def render
			t(:div, {},
				"usercomponents#show",
        t(:p,{}, (state.message if state.message)),
				t(:p, {}, 
					@user_id
				),
        t(:p, {onClick: ->(){logout_user}}, "click here to logout")
			)
		end

    def logout_user
      AppController.logout_user
    end

	end

end