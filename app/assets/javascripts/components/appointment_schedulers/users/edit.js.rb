module Components
  module AppointmentSchedulers
    module Users
      class Edit < RW
        
        expose

        include Plugins::Formable
        include Plugins::DependsOnCurrentUser
        set_roles_to_fetch :appointment_scheduler

        def get_initial_state
          {
            form_model: false
          }
        end


        def validate_props
          unless props.user
            p "===========#{self.class.name}============"
            p "required prop :user was not passed"
            p "props are #{Hash.new(props)}"
            p "========================================="
          end
        end

        def component_did_mount
          User.edit({wilds: {id: props.user.id}, namespace: 'appointment_scheduler', component: self}).then do |form_model|
            begin
            set_state form_model: form_model
            rescue Exception => e
              p e
            end
          end
        end

        def render
          t(:div, {},
            modal,
            progress_bar,
            if state.form_model
              t(:div, {},
                input(Forms::Input, state.form_model.profile, :name),
                t(:hr, {style: {color: "grey", height: "1px", backgroundColor: "black"}.to_n }),
                input(Forms::Input, state.form_model, :email),
                input(Forms::Input, state.form_model.profile, :phone_number),
                input(Forms::Input, state.form_model.profile, :bio),
                t(:button, {onClick: ->{handle_inputs}}, "update"),
                t(:button, {onClick: ->{cancel_edit}}, "cancel"),
                if !state.form_model.attributes[:registered]
                  t(:div, {},
                    t(:p, {}, 'this user is unregistered'),
                    t(:button, {onClick: ->{transform_user_to_registered(state.form_model)}}, 'register this user')
                  )
                end
              )
            end
          )
        end

        def handle_inputs
          collect_inputs(validate_only: [:phone_number, :bio])
          unless state.form_model.has_errors?
            state.form_model.update(namespace: 'appointment_scheduler').then do |model|

              unless model.has_errors?
                msg = Shared::Flash::Message.new(t(:div, {}, "updated successfully"))
                Components::App::Main.instance.ref(:flash).rb.add_message(msg)
                emit(:on_user_updated, model)
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

        def transform_user_to_registered(user)
          user.transform_user_to_registered(component: self).then do |user|
            state.form_model.attributes[:registered] = user.attributes[:registered]
            set_state form_model: state.form_model
            emit(:on_user_updated, state.form_model)
            alert 'user transformed to registered'
          end
        end


      end
    end
  end
end