module Components
  module Appointments
    module AppointmentSchedulers
      class Index < RW
        expose

        def get_initial_state
          {
            appointments: ModelCollection.new
          }
        end

        def component_did_mount
          Appointment.index(namespace: 'appointment_scheduler').then do |appointments|
            begin
            set_state appointments: appointments
            rescue Exception => e
              p e
            end
          end
        end

        def render
          t(:div, {},
            t(:table, {},
              t(:thead, {},
                t(:tr, {},
                  t(:th, {}, "id"), 
                  t(:th, {}, "for date"), 
                  t(:th, {}, "name"), 
                  t(:th, {}, "contacts"),
                  t(:th, {}, "chosen dates and doctors"),
                  t(:th, {}, ""),
                  t(:th, {}, ""),
                )
              ),
              t(:tbody, {},
                *splat_each(state.appointments) do |appointment|
                  t(:tr, {},
                    t(:td, {},
                      appointment.id
                    ),
                    t(:td, {},
                      Moment.new(appointment.start_date).format('YYYY-MM-DD')
                    ),
                    t(:td, {},
                      if appointment.patient.attributes[:registered]
                        t(:p, {}, appointment.patient.profile.try('name'))
                      else
                        t(:div, {},
                          t(:p, {}, "unregistered user"),
                          t(:p, {}, appointment.patient.profile.try('name'))
                        )
                      end
                    ),
                    t(:td, {},
                      t(:p, {}, appointment.patient.profile.attributes['phone_number'])
                    ),
                    t(:td, {},
                      *splat_each(appointment.appointment_proposal_infos) do |appointment_proposal_info|
                        t(:div, {},
                          if appointment_proposal_info.anytime_for_date
                            t(:p, {}, "any time for #{Moment.new(appointment_proposal_info.anytime_for_date).format('YYYY-MM-DD')}")
                          else
                            t(:p, {}, "#{appointment_proposal_info.doctor.profile.name}: #{Moment.new(appointment_proposal_info.date_from).format('HH:mm')} - #{Moment.new(appointment_proposal_info.date_to).format('HH:mm')}")
                          end
                        )
                      end
                    )       
                  )
                end
              )
            )
          ) 
        end

      end
    end
  end
end

