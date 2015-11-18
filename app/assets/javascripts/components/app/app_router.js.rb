module AppComponents

  class AppRouter < RW

    expose

    def component_will_unmount
      p "router will unmount"
    end

    def component_did_mount
      
    end
require_tree "../../components/shared/"
    def render
      t(`Router`, {history: Native(`window.History.createHistory()`)},
        t(`Route`, {path: "/", component: App.create_class},

          t(`Route`, {path: "/users", component: Users::Main.create_class}, 
            t(`Route`, {path: "signup", component: Users::SignUp.create_class }),
            t(`Route`, {path: "activations", component: Users::Activations.create_class}),
            t(`Route`, {path: "login", component: Users::Login.create_class}),
            t(`Route`, {path: "password_reset", component: Users::PasswordReset.create_class}),
            t(`Route`, {path: "update_new_password/:digest", component: Users::PasswordResetForm.create_class}),
            t(`Route`, {path: ":id", component: Users::Show.create_class})
          ),

          t(`Route`, {path: "forbidden", component: Components::App::Forbidden.create_class}),

          t(`Route`, {path: "test", component: Calendar.create_class}),

          t(`Route`, {path: "*", component: Components::App::NotFound.create_class})
        )
      )
    end 
  end
end

