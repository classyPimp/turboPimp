module	UserComponents

	BaseLink = "/users"


	class Main < RW
			
		def render
			t(:div, {}, 
				children
			)
		end

	end

end