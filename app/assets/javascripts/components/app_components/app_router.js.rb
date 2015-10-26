module AppComponents

	class AppRouter < RW

	  expose_as_native_component

    def component_will_unmount
	    p "router will unmount"
	  end

    def component_did_mount
      
    end

	  def render
	    t(`Router`, {history: Native(`History()`)},
	      t(`Route`, {path: "/", component: App.create_class},

	        t(`Route`, {path: "/users", component: UserComponents::Main.create_class}, 
	          t(`Route`, {path: "signup", component: UserComponents::Signup.create_class }),
	          t(`Route`, {path: "activations", component: UserComponents::Activations.create_class}),
	          t(`Route`, {path: ":id", component: UserComponents::Show.create_class}),
	          t(`Route`, {path: "login"}, component: UserComponents::Login.create_class)
	        )

	      )
	    )
	  end


	end
end

