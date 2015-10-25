module AppComponents

	class AppRouter < RW

	  expose_as_native_component

	  def init
	    @controller = AppController.new(self)
	  end

	  def component_will_mount
	    p "router will mount"
	  end

	  def component_will_update
	    p "router will update"
	  end

	  def component_will_unmount
	    p "router will unmount"
	  end

	  def render
	    t(`Router`, {history: Native(`History()`)},
	      t(`Route`, {path: "/", component: App.create_class},
	        t(`Route`, {path: "/about", component: About.create_class}),
	        t(`Route`, {path: "/home", component: Home.create_class},
	          t(`Route`, {path: "depot", component: Depot.create_class},
	          )
	        ),
	        t(`Route`, {path: "/users", component: UserComponents::Main.create_class}, 
	          t(`Route`, {path: "new", component: UserComponents::CreateUser.create_class },
	          ),
	          t(`Route`, {path: "activations", component: UserComponents::Activations.create_class},
	          ),
	          t(`Route`, {path: ":id", component: UserComponents::Show.create_class})
	        )
	      )
	    )
	  end


	end
end