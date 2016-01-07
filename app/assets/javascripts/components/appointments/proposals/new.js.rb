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
          form_model: Appointment.new(appointment_detail: {appointment_detail: {proposal_info: {}}})
        end

        def render
          t(:div, {},
            t(:div, {},
              *splat_each(props.appointment_availabilities)) do |k, v|
                t(:span, {},
                  "#{k}",
                  t(:br, {}),
                  *splat_each(v[0].map) do |av|
                    t(:span, {}, "#{av[0].format('HH:mm')} - #{av[1].format('HH:mm')}", t(:br, {}))
                  end,
                  "------------",
                  t(:br, {})

                )
              end
            )         
          )           
        end

      end
    end
  end
end
