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
          }
        end

        def render
          t(:div, {},
            modal,
            "any time on this date",
            input(Forms::PushCheckBox, state.form_model, :appointment_proposal_infos, {push_value: AppointmentProposalInfo.new(any_time_for_date: props.date.format('YYYY-MM-DD'))}),
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
              t(:button, {onClick: ->{handle}}, "collect")
            )         
          )           
        end

        def handle
          collect_inputs
          if !CurrentUser.logged_in
            post_modal
          else
            submit
          end
        end

        def submit(options = {})
          modal_close unless options.empty?

          unless options[:logged_in]
            user = options[:non_register_info] if options[:non_register_info]
          end

          unless state.form_model.has_errors?
            state.form_model.create(extra_params: user.pure_attributes).then do |model|
              if model.has_errors?
                set_state form_model: model
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

        def post_modal
          modal_open(
            "hey,",
            t(PostModal, { on_ready: event(->(options){self.submit(options)}) })
          )
        end

      end

      class PostModal < RW
        expose

        include Plugins::Formable

        def get_initial_state
          {
            form_model: User.new(profile: Profile.new),
            step: 0
          }
        end

        def render
          unless CurrentUser.logged_in
            t(:div, {},
              modal,
              if state.step == 0
                t(:div, {},  
                  t(:p, {}, "it looks like you are not a registered user or you didn't login, as though you don't need to register you're required to leave contact information"),
                  t(:p, {}, "you will become a registered user if you will leave your email and will fill in password, else you will not be registerd"),
                  t(:button, {onClick: ->{open_login_box}}, "i'ma registered user"),
                  t(:button, {}, "ok i will register"),
                  t(:button, {onClick: ->{set_state(step: 1)}}, "i won't register i'll just leave my contact info")
                )
              elsif state.step == 1
                t(:div, {}, 
                  t(:div, {}, 
                    input(Forms::Input, state.form_model.profile, :name),
                    input(Forms::Input, state.form_model.profile, :phone),
                    t(:button, {onClick: ->{submit_non_register_info}}, "submit"),
                    t(:button, {onClick: ->{set_state(step: 0)}}, "back")
                  )
                )
              end
            ) 
          end
        end

        def submit_non_register_info  
          collect_inputs
          unless state.form_model.has_errors?
            self.emit(:on_ready, {non_register_info: state.form_model})
          else
            set_state form_model: state.form_model
          end
        end

        def open_login_box
          modal_open("", t(Components::Users::Login, {on_login: event(->(user){logged_in(user)}), no_redirect: true}))
        end

        def logged_in(user)
          emit('on_ready', {logged_in: true})
          modal_close
        end

      end
    end
  end
end
