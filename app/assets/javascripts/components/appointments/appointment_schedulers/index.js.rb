module Components
  module Appointments
    module ApointmentSchedulers
      class Index < RW
        expose

        def state
          {
            appointments: ModelCollection.new
          }
        end

        def render
          t(:div, {},
            t(:div, {},
              t(:span, {}, "id"), 
              t(:span, {}, "for date"), 
              t(:span, {}, "name"), 
              t(:span, {}, "contacts"),
              t(:span, {}, "chosen dates and doctors"),
              t(:span, {}, ""),
              t(:span, {}, ""),
            ),
            state.appointments.each do |appointment|
              t(:div, {},
                t(:div, {},
                  appointment.id
                ),
                t(:div, {},
                  Moment.new(appointment.start_date).format
                ),
                t(:div, {},
                  appointment.patient.profile.name
                ),
                t(:div, {},
                  appointment_infos.each 
                )
              )
            end
          ) 
        end

      end
    end
  end
end