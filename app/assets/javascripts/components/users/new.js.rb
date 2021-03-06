module Components
  module Users
    class New < RW
      expose

      include Plugins::Formable

      include Plugins::DependsOnCurrentUser
      set_roles_to_fetch :admin

      def prepare_new_user
        ->{
          User.new(profile: {profile: {}}, avatar: {avatar: {}}, roles: [])
        }
      end

      def get_initial_state
        {
          form_model: prepare_new_user.call
        }
      end

      def render
        t(:div, {className: 'create_user_form'},
          if state.form_model
            t(:div, {className: "form"},
              input(Forms::Input, state.form_model.profile, :name, {show_name: 'name'}),
              input(Forms::Input, state.form_model, :email, {type: "text", show_name: 'email'}),
              input(Forms::Input, state.form_model, :password, {type: "password", show_name: 'password'}),
              input(Forms::Input, state.form_model, :password_confirmation, {type: "password", show_name: 'confirm password'}),
              input(Forms::WysiTextarea, state.form_model.profile, :bio, {show_name: 'biography'}),
              input(Forms::FileInputImgPreview, state.form_model.avatar, :file, {show_name: 'avatar'}),
              if state.current_user.has_role? :admin
                t(:div, {},
                  t(:p, {}, "choose roles for user"),
                  input(Forms::Select, state.form_model, :roles, {multiple: true, server_feed: {url: "/api/users/roles_feed"},
                                                                  option_as_model: 'role', s_value: "name", show_name: ''})
                )
              end, 
              t(:button, {onClick: ->(){handle_inputs}}, "create user")
            )
          end 
        )
      end

      def handle_inputs
        collect_inputs
        p state.form_model.pure_attributes
        unless state.form_model.has_errors?
          state.form_model.create(serialize_as_form: true, namespace: "admin").then do |model|
            begin
            if model.has_errors?
              set_state form_model: model
            else
              if props.on_create
                props.on_create(model)
              end
              create_flash(link_to("new user created", "/users/show/#{model.id}"))
              props.history.pushState(nil, '/users/dashboard')
            end
          rescue Exception => e
            p e
          end
          end
        else
          set_state form_model: state.form_model
        end
      end

    end
  end
end