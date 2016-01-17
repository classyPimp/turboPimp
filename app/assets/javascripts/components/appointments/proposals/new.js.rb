module Components
  module Appointments
    module Proposals
      class New < RW
        expose
        include Plugins::Formable

        #PROPS
        #appointment_availabilities: ModelCollection of AppointmentAvailability will be offered to select
        #start_date: Moment, from this moment one week ahead will be offered like mon before noon after noon checkboxes
        def get_initial_state
          @blank_appointment = ->{Appointment.new(appointment_proposal_infos: [])}
          {
            form_model: @blank_appointment.call,
            step: 0
          }
        end

        def render
          t(:div, {},
            if state.step == 0
              t(:div, {},
                "any time on this date",
                input(Forms::PushCheckBox, state.form_model, :appointment_proposal_infos, {push_value: AppointmentProposalInfo.new(anytime_for_date: props.date.format('YYYY-MM-DD'))}),
                t(:div, {},
                  *splat_each(props.appointment_availabilities) do |k, v|
                    t(:span, {},
                      "#{k}",
                      t(:br, {}),
                      *splat_each(v[0].map) do |av|
                        t(:div, {},
                          t(:span, {}, "#{av[0].format('HH:mm')} - #{av[1].format('HH:mm')}", t(:br, {})),
                          input(Forms::PushCheckBox, state.form_model, :appointment_proposal_infos, 
                            {checked: false, push_value: AppointmentProposalInfo.new(primary: true, doctor_id: v[0].user_id, date_from: av[0].format, date_to: av[1].format)}
                          )   
                        )
                      end,
                      "------------",
                      t(:br, {})
                    )
                  end,
                  t(:button, {onClick: ->{handle_before_appointment_submit}}, "collect")
                )
              )
            elsif state.step == 1
              t(:div, {},  
                t(:p, {}, "it looks like you are not a registered user or you didn't login, as though you don't need to register you're required to leave contact information"),
                t(:p, {}, "you will become a registered user if you will leave your email and will fill in password, else you will not be registerd"),
                t(:button, {onClick: ->{open_login_box}}, "i'ma registered user"),
                t(:button, {}, "ok i will register NOT IMPLEMENTED"),
                t(:button, {onClick: ->{ init_non_registered_user } }, "i won't register i'll just leave my contact info")
              )
            elsif state.step == 2
              t(:div, {}, 
                t(:div, {}, 
                  input(Forms::Input, state.user_form_model.profile, :name),
                  input(Forms::Input, state.user_form_model.profile, :phone_number),
                  t(:button, { onClick: ->{submit_non_register_info} }, "submit"),
                  t(:button, { onClick: ->{set_state(step: 1)} }, "back")
                )
              )
            end                  
          )           
        end

        def handle_before_appointment_submit
          collect_inputs
          if !CurrentUser.logged_in
            set_state step: 1, user_form_model: User.new(profile: Profile.new)
          else
            submit_appointment
          end
        end

        def submit_appointment(options = {})
          
          unless options[:logged_in]

            if options[:non_registered]

              extra_params = {extra_params: state.user_form_model.pure_attributes} 

            end

          end

          extra_params ||= {}

          unless state.form_model.has_errors?

            state.form_model.create( {yield_response: true}.merge(extra_params) ).then do |model|
              
              model = Model.parse(model.json)
              model.validate

              if model.has_errors? || model.is_a?(User)

                if model.is_a?(User)
 
                  set_state(user_form_model: model, step: 2)

                else

                  set_state form_model: model, step: 0

                end

              else

                msg = Shared::Flash::Message.new(t(:div, {}, 
                                                  t(:p, {}, "your appointment will be reviewed by stuff and you will be contacted thank you")
                                                ))
                Components::App::Main.instance.ref(:flash).rb.add_message(msg)
                self.props.on_appointment_proposal_created()

              end

            end
          else
            set_state form_model: state.form_model
          end

        end

        def init_non_registered_user
          set_state( step: 2, user_form_model: User.new(profile: Profile.new) )
        end

        def submit_non_register_info  
          
          collect_inputs(form_model: 'user_form_model')
          state.user_form_model.validate

          unless state.user_form_model.has_errors?
            submit_appointment( non_registered: true )
          else
            set_state user_form_model: state.user_form_model
          end
          
        end

        def open_login_box
          modal_open("", t(Components::Users::Login, {on_login: event(->(user){logged_in(user)}), no_redirect: true}))
        end

        def logged_in(user)
          modal_close
          submit(logged_in: true)
        end

      end
    end
  end
end
