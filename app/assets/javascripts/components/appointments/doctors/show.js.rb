module Components
  module Appointments  
    module Doctors
      class Show < RW
        expose

        def get_initial_state
          {
            appointment: false
          }
        end

        def component_did_mount
          Appointment.show(wilds: {id: props.appointment.id}, component: self, namespace: "doctor").then do |appointment|
            state.start_date = Moment.new appointment.start_date
            state.end_date = Moment.new appointment.end_date
            set_state appointment: appointment
          end
        end

        def render
          t(:div, {},
            spinner,
            if state.appointment
              t(:div, {},
                t(:p, {}, "patient:"),
                t(:p, {}, "#{state.appointment.patient.profile.name}"),
                t(:p, {}, "time"),
                t(:p, {}, "#{state.start_date.format('HH:mm')} - #{state.end_date.format('HH:mm')}"),
                t(:p, {}, "info"),
                t(:p, {}, "#{state.appointment.appointment_detail.note}")
              )
            end
          )
        end

      end
    end
  end
end