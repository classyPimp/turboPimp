module UserComponents

	class Show < RW
		
		def init
			@user_id = self.props.params.id
			`console.log(#{props.params.id})`
		end

    def initial_state
      {
        message: nil
      }
    end

		def render
			t(:div, {},
				"usercomponents#show",
        t(:p,{}, (state.message if state.message)),
				t(:p, {}, 
					@user_id
				),
        t(:p, {onClick: ->(){logout_user}}, "click here to logout"),
        t(:p, {onClick: ->(){App.history.replaceState(nil, "/about")}}, "click to relocate")
			)
		end

    def logout_user
      AppController.logout_user
    end

	end

end