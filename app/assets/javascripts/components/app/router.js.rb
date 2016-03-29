require_tree "../../components/shared/"
module Components
  module App
    class Router < RW

      expose
      
      @@history = Native(`window.browserHistory()`)

      def self.history
        @@history
      end

      def get_initial_state
        Components::App::Main.props_from_server = self.props
        {}
      end

      def render
        t(`Router`, {history: @@history.to_n},
          t(`Route`, {path: "/", component: Components::App::Main.create_class},
            t(`IndexRoute`, {component: Components::App::IndexRoute.create_class}),

            t(`Route`, {path: 'contacts', component: Components::SpecificPages::Contacts.create_class}),


            t(`Route`, {path: "/users", component: Users::Main.create_class}, 
              t(`Route`, {path: "signup", component: Users::SignUp.create_class }),
              t(`Route`, {path: "activations", component: Users::Activations.create_class}),
              t(`Route`, {path: "login", component: Users::Login.create_class}),
              t(`Route`, {path: "password_reset", component: Users::PasswordReset.create_class}),
              t(`Route`, {path: "update_new_password/:digest", component: Users::PasswordResetForm.create_class}),
              t(`Route`, {path: "new", component: Users::New.create_class}),
              t(`Route`, {path: "dashboard", component: Components::Users::Dashboard::Main.create_class},
                t(`Route`, {path: 'new_user', component: Components::Users::New.create_class}),
                t(`Route`, {path: 'users_index', component: Components::Users::Index.create_class}),
                t(`Route`, {path: 'edit_menu', component: Components::Menues::IndexEdit.create_class}),
                t(`Route`, {path: 'create_page', component: Components::Pages::New.create_class}),
                t(`Route`, {path: 'pages_index', component: Components::Pages::Index.create_class}),
                t(`Route`, {path: 'edit_price_list', component: Components::Admin::Prices::Index.create_class}),
                t(`Route`, {path: 'create_blog', component: Components::Blogs::New.create_class}),
                t(`Route`, {path: 'last_blogs', component: Components::Blogger::Blogs::LastTen.create_class}),
                t(`Route`, {path: 'blogs_index', component: Components::Blogs::Index.create_class}),
                t(`Route`, {path: 'doctor_appointments', component: Components::Appointments::Doctors::Index.create_class}),
                t(`Route`, {path: 'appointments_proposals', component: Components::Appointments::AppointmentSchedulers::ProposalIndex.create_class} ),
                t(`Route`, {path: 'browse_schedule', component: Components::Appointments::AppointmentSchedulers::Index.create_class}),
                t(`Route`, {path: 'register_patient', component: Components::AppointmentSchedulers::Users::New.create_class}),
                t(`Route`, {path: 'manage_patients', component: Components::AppointmentSchedulers::Users::Index.create_class}),
                t(`Route`, {path: 'browse_chats', component: Components::AppointmentSchedulers::ChatMessages::Index.create_class})
              ),
              t(`Route`, {path: "show/:id", component: Users::Show.create_class}),
              t(`Route`, {path: ":id/edit", component: Users::Edit.create_class})
            ),

            t(`Route`, {path: "/pages", component: Components::Pages::Main.create_class},
              t(`Route`, {path: "new", component: Components::Pages::New.create_class}),
              t(`Route`, {path: "index", component: Components::Pages::Index.create_class}), 
              t(`Route`, {path: ":id/edit", component: Components::Pages::Edit.create_class}),           
              t(`Route`, {path: "show/:id", component: Components::Pages::Show.create_class})
            ),

            t(`Route`, {path: "/images", component: Components::Images::Main.create_class},
              t(`Route`, {path: "index", component: Components::Images::Index.create_class}),
              t(`Route`, {path: "new", component: Components::Images::Create.create_class})
            ),

            t(`Route`, {path: "/admin", component: Components::Admin::Main.create_class, onEnter: ->(n, r, cb){check_role(n, r, cb, [:admin])}},
              t(`Route`, {path: "users/:id/edit", component: Components::Admin::Users::Edit.create_class}),

              t(`Route`, {path: 'offered_services/new', component: Components::Admin::OfferedServices::New.create_class})
            ),

            t(`Route`, {path: "price_list", component: Components::PriceList::Index.create_class}),

            t(`Route`, {path: "/blogs", component: Components::Blogs::Main.create_class},
              t(`Route`, {path: "index", component: Components::Blogs::UserIndex.create_class}),
              # t(`Route`, {path: "new", component: Components::Blogs::New.create_class}),
              t(`Route`, {path: "edit/:id", component: Components::Blogs::Edit.create_class}),
              t(`Route`, {path: "show/:id", component: Components::Blogs::Show.create_class})
            ),

            t(`Route`, {path: "/appointments", component: Components::Appointments::Main.create_class},
              t(`Route`, {path: "index", component: Components::Appointments::Index.create_class})
            ),

            # t(`Route`, {path: "/blogger", component: Components::Blogger::Blogs::Main.create_class},
            #   t(`Route`, {path: "blogs/dashboard", component: Components::Blogger::Blogs::Dashboard.create_class})
            # ),

            # t(`Route`, {path: "menues/index_edit", component: Components::Menues::IndexEdit.create_class}),

            t(`Route`, {path: "forbidden", component: Components::App::Forbidden.create_class}),

            t(`Route`, {path: "test", component: Components::Dummy::A.create_class}),

            t(`Route`, {path: "calendar", component: Calendar.create_class}),

            t(`Route`, {path: '/personnel', component: Components::Doctors::Index.create_class},
              t(`Route`, {path: ':id', component: Components::Doctors::Show.create_class})
            ),

            
            t(`Route`, {path: "404", component: Components::App::NotFound.create_class}), 
            t(`Route`, {path: "*", component: Components::App::NotFound.create_class})
          )
        )
      end 

      def check_role(next_state, replace_state, cb, role)
        CurrentUser.get_current_user(extra_params: {roles: [:admin, :root]}).then do |user|
          CurrentUser.user_instance = user
          if user.has_role? role
            `cb()`
          else
            @@history.replaceState({}, "/forbidden")
          end
        end.fail do |resp|
          @@history.replaceState({}, "/forbidden")
        end 
      end
    end
  end
end
=begin
loading files separately
Document.ready? do
  HTTP.get("/api/restricted_asset", payload: {file: "foo.js.rb"}) do |r|
    if r.ok? 
      `eval(r)`
      #{}`Opal.load("Foo")`
      Foo.foo
    end
  end
end
=end
