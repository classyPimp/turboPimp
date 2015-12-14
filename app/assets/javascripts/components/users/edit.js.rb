module Components
  module Users
    class Edit < RW
      expose

      include Plugins::Formable

      def get_initial_state
        {
          form_model: false
        }
      end

      def component_did_mount
        id = props.params.id
        unless CurrentUser.user_instance.id == id.to_i
          props.history.replaceState({}, "/forbidden")
        else
          User.show({id: id}).then do |form_model|
            set_state form_model: form_model
          end
        end
      end

      def render
        t(:div, {},
          modal,
          if state.form_model
            define_modal_contents
            t(:div, {},
              t(:h3, {}, input(Forms::Input, state.form_model.profile, :name)),
              t(:hr, {style: {color: "grey", height: "1px", backgroundColor: "black"}}),
              t(:image, {src: state.form_model.avatar.try(:url), style: {width: "60px", height: "60px"}}),
              t(:p, {}, "updload new avatar"),
              input(Forms::Input, state.form_model.avatar, :file, {type: "file", has_file: true, preview_image: true}),
              t(:p, {}, "email: #{state.form_model.email}"),
              t(:button, {onClick: ->{init_auth_data_edit}}, "edit login credentials"),
              input(Forms::Input, state.form_model.profile, :bio),
              t(:button, {onClick: ->{handle_inputs}}, "update"),
              t(:button, {onClick: ->{cancel_edit}}, "cancel"),
            )
          end
        )
      end

      def handle_inputs
        collect_inputs
        unless state.form_model.has_errors?
          state.form_model.update({}, {serialize_as_form: true}).then do |model|
            unless model.has_errors?
              msg = Shared::Flash::Message.new(t(:div, {}, "updated successfully"))
              Components::App::Main.instance.ref(:flash).rb.add_message(msg)
              props.history.pushState({}, "/users/show/#{model.id}")
              modal_close
            else
              set_state form_model: model
            end
          end
        else
          set_state form_model: state.form_model
        end
      end

      def cancel_edit
        props.history.go(-1)
      end

      def init_auth_data_edit
        CurrentUser.get_current_user.then do |user|
          if user.id == state.form_model.id
            modal_open(@head_content, @content)
          else
            props.history.replaceState({}, "/forbidden")
          end
        end
        
      end

      def define_modal_contents
        @head_content = t(:p, {}, "edit auth data")
        @content = 
          t(:div, {},
            t(:p, {}, "current email: #{state.form_model.email}"),
            t(:p, {}, "new email"),
            input(Forms::Input, state.form_model, :email),
            t(:br, {}),
            input(Forms::Input, state.form_model, :password),
            input(Forms::Input, state.form_model, :password_confirmation),
            t(:br, {}),
            t(:button, {onClick: ->{handle_inputs} }, "update")
          )
      end

    end
  end
end