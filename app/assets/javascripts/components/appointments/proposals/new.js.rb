module Components  
  module Appointments  
    module Proposals
      class New < RW
        expose
        include Plugins::Formable

        #PROPS  
        #appointment_availabilities: ModelCollection of AppointmentAvailability will be offered to select
        #start_date: Moment, from this moment one week ahead will be offered like mon before noon after noon checkboxes
        def validate_props
          unless props.date.is_a?(Moment) && props.date
            p "=======#{self.class.name}===="
            p "props.date required to be Moment nil or other provided: #{props.date.class}#{props.date}"
          end

          unless props.appointment_availabilities || props.user_accessor
            p "=========#{self.class.name}===="
            p 'props.appointment_availabilities or props.user_accessor not provided or provided not of required type'
          end
        end

        def get_initial_state
          @blank_appointment = ->{Appointment.new(start_date: props.date.startOf('day').format(), appointment_proposal_infos: [], appointment_detail: AppointmentDetail.new)}
          {
            form_model: @blank_appointment.call,
            step: 0,
            any_time_toggled: false
          }
        end

        def render
          t(:div, {className: 'appointment_proposal_new'},
            modal,
            if state.step == 0
              t(:div, {},
                if state.message
                  t(:p, {}, state.message)
                end,
                t(:div, {className: "checkbox_desc_group"},
                  t(:span, {onClick: ->{any_time_toggled}},
                    input(Forms::PushCheckBox, state.form_model, :appointment_proposal_infos, {show_name: '',className: 'checkbox any_time', push_value: AppointmentProposalInfo.new(anytime_for_date: props.date.format('YYYY-MM-DD'))}),
                  ),
                  t(:div, {className: 'time_range'}, 
                    t(:p, {}, "anytime for this date")
                  )
                ),
                t(:div, {},
                  unless state.any_time_toggled
                    t(:span, {},
                      *splat_each(props.appointment_availabilities) do |k, v|
                        t(:div, {},
                          t(:div, {className: "doc_name_and_avatar"},
                            t(:img, {src: "#{props.user_accessor[k].avatar.url}", className: 'doctor_avatar'}),
                            t(:span, {className: 'doctor_name'}, 
                              "#{props.user_accessor[k].profile.name}"
                            )
                          ),
                          *splat_each(v[0].map) do |av|
                            t(:div, {className: "checkbox_desc_group"},
                              input(Forms::PushCheckBox, state.form_model, :appointment_proposal_infos, 
                                {className: 'checkbox', show_name: '',checked: false, push_value: AppointmentProposalInfo.new(primary: true, doctor_id: v[0].user_id, date_from: av[0].format, date_to: av[1].format)}
                              ),
                              t(:div, {className: 'time_range'}, 
                                t(:p, {}, "#{av[0].format('HH:mm')} - #{av[1].format('HH:mm')}")
                              )
                            )
                          end
                        )
                      end
                    )
                  end,
                  t(:div, {className: 'extra_details'},
                    t(:p, {}, 'please provide the reason for visit, e.g. general consultation'),
                    input(Forms::Textarea, state.form_model.appointment_detail, :extra_details, {show_name: '', className: 't_area'}),
                  ),
                  t(:button, {className: 'btn btn-primary',onClick: ->{handle_before_appointment_submit}}, "collect")
                )
              )
            elsif state.step == 1
              t(:div, {className: 'not_logged_in_step'},  
                t(:p, {}, "it looks like you are not a registered user or you didn't login, as though you don't need to register you're required to leave contact information"),
                t(:p, {}, "you will become a registered user if you will leave your email and will fill in password, else you will not be registerd"),
                t(:div, {className: 'login_button_group'}, 
                  t(:button, {className: 'btn btn-success', onClick: ->{init_login}}, "i'ma registered user"),
                  t(:button, {className: 'btn btn-success'}, "ok i will register NOT IMPLEMENTED"),
                  t(:button, {className: 'btn btn-success', onClick: ->{ init_non_registered_user } }, "i won't register i'll just leave my contact info")
                )
              )
            elsif state.step == 2
              t(:div, {className: 'guest_step'}, 
                t(:div, {className: 'guest_appointment_form'}, 
                  input(Forms::Input, state.user_form_model.profile, :name, {show_name: 'your name'}),
                  input(Forms::Input, state.user_form_model.profile, :phone_number, {show_name: 'your phone_number'}),
                  t(:button, { onClick: ->{submit_non_register_info} }, "submit"),
                  t(:button, { onClick: ->{set_state(step: 1)} }, "back")
                )
              )
            end                  
          )           
        end

        def any_time_toggled
          set_state any_time_toggled: !state.any_time_toggled
        end

        def handle_before_appointment_submit
          collect_inputs
          state.message = false
          if state.form_model.appointment_proposal_infos.length < 1
            set_state step: 0, form_model: state.form_model, message: 'please choose at least one option of visit'
          elsif state.form_model.has_errors?
            set_state step: 0, form_model: state.form_model
          elsif !CurrentUser.logged_in
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
              begin
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
                emit :on_appointment_proposal_created

              end
              rescue Exception => e
                p e
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

        def init_login
          modal_open("", t(Components::Users::Login, {on_login: event(->{logged_in}), no_redirect: true}))
        end

        def logged_in(user)
          modal_close
          set_state(step: 0)
          submit_appointment(logged_in: true)
        end

      end
    end
  end
end
