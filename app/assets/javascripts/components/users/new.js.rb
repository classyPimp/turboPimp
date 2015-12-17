module Components
  module Users
    class New < RW
      expose

      include Plugins::Formable

      include Plugins::DependsOnCurrentUser
      set_roles_to_fetch :admin

      def prepare_new_user
        ->{
          User.new(profile: {profile: {}}, avatar: {avatar: {}})
        }
      end

      def get_initial_state
        {
          form_model: prepare_new_user.call
        }
      end

      def render
        t(:div, {},
          if state.form_model
            t(:div, {className: "form"},
              input(Forms::Input, state.form_model.profile, :name),
              input(Forms::Input, state.form_model, :email, {type: "text"}),
              input(Forms::Input, state.form_model, :password, {type: "password"}),
              input(Forms::Input, state.form_model, :password_confirmation, {type: "password"}),
              input(Forms::Textarea, state.form_model.profile, :bio),
              input(Forms::Input, state.form_model.avatar, :file, {type: "file", has_file: true, preview_image: true}),
              if state.current_user.has_role? :admin
                t(:div, {},
                  t(:p, {}, "choose roles"),
                  input(Forms::Select, state.form_model, :roles_array, {multiple: true, server_feed: {url: "/api/users/roles_feed"}})
                )
              end,
              t(:br, {}),
              t(:button, {onClick: ->(){handle_inputs}}, "create user")
            )
          end 
        )
      end

      def handle_inputs
        collect_inputs
        unless state.form_model.has_errors?
          state.form_model.create({}, {serialize_as_form: true}).then do |model|
            if model.has_errors?
              set_state form_model: model
            else
              props.on_create(model)
            end
          end
        else
          set_state form_model: state.form_model
        end
      end

    end
  end
end