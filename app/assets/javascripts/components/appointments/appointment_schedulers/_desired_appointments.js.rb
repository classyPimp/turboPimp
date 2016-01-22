module Components
  module Appointments
    module AppointmentSchedulers
      module Partials
        class DesiredAppointments < RW
          #User in Components::Appointments::AppointmentScheduler::ProposalIndex and Index
          expose

          # PROPS
          # proposal_infos - required ModelCollection, this will be iterated and show the appointment proposals from user
          #                  on his chosen dates. in Index it is used for scheduler to show above calendar as reference
          
          def render
            t(:div, {},
              *splat_each(props.appointment_proposal_infos) do |appointment_proposal_info|
                t(:div, {},
                  if appointment_proposal_info.anytime_for_date
                    t(:p, {}, "any time for #{Moment.new(appointment_proposal_info.anytime_for_date).format('YYYY-MM-DD')}")
                  else
                    t(:p, {}, "#{appointment_proposal_info.doctor.profile.name}: #{Moment.new(appointment_proposal_info.date_from).format('HH:mm')} - #{Moment.new(appointment_proposal_info.date_to).format('HH:mm')}")
                  end
                )
              end
            )
          end

        end
      end
    end
  end
end