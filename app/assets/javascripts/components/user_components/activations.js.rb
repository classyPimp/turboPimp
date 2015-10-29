module Users

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
					link_to("to users::show", "/users/#{@id}")
				end
			)
		end

		def component_did_mount
			
		end

	end

end