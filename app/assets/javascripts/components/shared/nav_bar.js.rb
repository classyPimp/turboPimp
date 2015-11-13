module Shared
	class Nav < RW
		expose
		def render		
			t(:nav, {className: "navbar navbar-default"},
				t(:div, {className: "container-fluid"},
					t(:div, {className: "navbar-header"},
						t(:p, {className: "navbar-brand"}, 
							"PREESSS HEADER"
						)
					),
					t(:form, {className: "navbar-form navbar-left"},
						t(:div, {className: "form-group"},
							t(:input, {className: "form-control"})
						),
						t(:button, {className: "btn btn-default"},
							"submit"
						)
					)
				)
			)

		end

	end	

end
