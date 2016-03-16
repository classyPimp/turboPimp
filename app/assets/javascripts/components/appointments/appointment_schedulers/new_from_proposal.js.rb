module Components
  module Appointments
    module AppointmentSchedulers
      class NewFromProposal < RW
        expose

        #component serves to shedule an appointment on proposal, it accepts a proposal appointment
        # infers the patient and it's id and let's scheduler to choose dates, 
        # it also uses the prosal times and doctors that patient chose
        # the default date YYYY-MM-DD is passed as prop, the scheduler set HH mm
        # => PROPS
        #  appointment_proposal_infos: ModelCollection of ProposalInfo with included patient doctor and their profiles
        #  date: Moment instance with date set to startOf('day')

        include Plugins::Formable

        def get_initial_state
          a = props.appointment
          a_id = a.id
          a_p_id = a.patient_id
          {
            form_model: Appointment.new(id: a_id, patient_id: a_p_id),
          }
        end

        def render
          t(:div, {},
            t(:div, {className: 'row'},
              t(:div, {className: 'col-lg-6'},
                t(:p, {}, "patient: #{props.appointment.patient.profile.name}"),
                t(:date, {}, "date: #{props.date.format('YYYY-MM-DD')}"),
                input(Forms::Input, state.form_model, :time_part_from),
                input(Forms::Input, state.form_model, :time_part_to),
                input(Forms::Select, state.form_model, :doctor_id, {multiple: false, s_value: 'name', 
                                                                   option_as_model: true, 
                                                                   server_feed: {url: "/api/doctor/users/doctors_feed"}}),
                t(:button, {onClick: ->{handle_submit}}, 'schedule appointment')
              ),
              t(:div, {className: 'col-lg-6'},
                t(Components::Appointments::AppointmentSchedulers::Partials::DesiredAppointments, 
                  {appointment_proposal_infos: props.appointment.appointment_proposal_infos}
                )
              )
            )
          )
        end

        def handle_submit
          collect_inputs(validate: false)

          s_a = state.form_model.attributes

          s_a[:doctor_id] = s_a[:doctor_id].try(:attributes)[:user_id]

          start_str = "#{props.date.format('YYYY-MM-DD')}T#{s_a.delete(:time_part_from)}"
          end_str = "#{props.date.format('YYYY-MM-DD')}T#{s_a.delete(:time_part_to)}"

          state.form_model.start_date = Moment.new(start_str, 'YYYYMMDDHHmm').format()
          state.form_model.end_date = Moment.new(end_str, 'YYYYMMDDHHmm').format()

          state.form_model.validate

          unless state.form_model.attributes[:doctor_id]
            state.form_model.add_error(:doctor_id, 'please choose doctor')
          end

          unless state.form_model.has_errors?

            state.form_model.schedule_appointment(namespace: 'appointment_scheduler').then do |appointment|
              unless appointment.has_errors?
                emit(:on_appointment_created)
              else
                state.form_model.attributes.delete(:doctor_id)
                set_state form_model: state.form_model
              end
            end

          else
            
            state.form_model.attributes.delete(:doctor_id)
            set_state form_model: state.form_model

          end

        end

      end
    end
  end
end