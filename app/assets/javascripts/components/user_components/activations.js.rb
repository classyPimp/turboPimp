module UserComponents

	class Activations < RW
		
		def init
			if id = props.location.query.id
				@ok = true
				@message = "successfully activated account"
				@id = id
			else
				@ok = false
				@message = "there was an error in activating your account"
			end
		end

		def render
			t(:div, {}, 
				t(:p,{}, @message),
				if @ok
					t(`Link`, {to: "/users/#{@id}"}, "go to my settings")
				end
			)
		end

		def component_did_mount
			
		end

	end

end