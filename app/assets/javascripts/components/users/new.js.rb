module Users
  class New < RW
    expose

    include Plugins::Formable

    def prepare_new_user
      ->{
        User.new(profile: {profile: {}}, avatar: {avatar: {}})
      }
    end

    def initial_state
      {
        form_model: prepare_new_user
      }
    end

    def render
      t(:div, {},
        t(:div, {className: "form"},
          input(Forms::Input, state.form_model, :email, {type: "text"}),
          input(Forms::Input, state.form_model, :password, {type: "password"}),
          input(Forms::Input, state.form_model, :password_confirmation, {type: "password"}),
          input(Forms::Textarea, state.form_model.profile, :bio),
          input(Forms::Input, state.form_model.avatar, :file, {type: "file", has_file: true, preview_image: true}),
          t(:br, {}),
          t(:button, {onClick: ->(){handle_inputs}}, "create user")
        )
      )
    end

  end
end
