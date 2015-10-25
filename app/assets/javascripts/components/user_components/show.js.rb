module UserComponents

	class Show < RW
		
		def init
			@user_id = self.props.params.id
			`console.log(#{props.params.id})`
		end

		def render
			t(:div, {},
				"usercomponents#show",
				t(:p, {}, 
					@user_id
				)
			)
		end

	end

end