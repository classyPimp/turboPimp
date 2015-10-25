module	UserComponents

	class Main < Bar
			
		def render
			t(:div, {}, 
				children
			)
		end

	end

end