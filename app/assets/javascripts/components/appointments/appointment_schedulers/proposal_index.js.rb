module Components
  module Appointments
    module AppointmentSchedulers
      class ProposalIndex < RW

        expose

        def get_initial_state
          {
            appointments: ModelCollection.new
          }
        end

        def component_did_mount
          Appointment.proposal_index(namespace: 'appointment_scheduler').then do |appointments|
            begin
            set_state appointments: appointments
            rescue Exception => e
              p e
            end
          end
        end

        def render
          @dates_and_doctors_ids = Hash.new { |hash, key| hash[key] = [] }

          t(:div, {},
            modal,
            t(:table, {className: 'table-bordered table-striped table-responsive'},
              t(:thead, {},
                t(:tr, {},
                  t(:th, {}, "id"), 
                  t(:th, {}, "for date"), 
                  t(:th, {}, "name"), 
                  t(:th, {}, "contacts"),
                  t(:th, {}, 'note from patient'),
                  t(:th, {}, "chosen dates and doctors"),
                  t(:th, {}, ""),
                  t(:th, {}, ""),
                  t(:th, {}, "")
                )
              ),
              t(:tbody, {},
                *splat_each(state.appointments) do |appointment|
                  next unless appointment.patient && appointment.patient.profile
                  t(:tr, {key: appointment.id},
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
                          t(:p, {}, appointment.patient.profile.try('name')),
                          t(:p, { onClick: ->{delete_unregistered_users_with_proposals(appointment.patient)} }, 'delete this user and all his proposals')
                        )
                      end
                    ),
                    t(:td, {},
                      t(:p, {}, appointment.patient.profile.try(:phone_number))
                    ),
                    t(:td, {}, 
                      t(:p, {},
                        appointment.appointment_detail.extra_details
                      )
                    ),
                    t(:td, {},
                      *splat_each(appointment.appointment_proposal_infos) do |appointment_proposal_info|
                        t(:div, {},
                          if appointment_proposal_info.anytime_for_date
                            t(:p, {}, "any time for #{Moment.new(appointment_proposal_info.anytime_for_date).format('YYYY-MM-DD')}")
                          else
                            @dates_and_doctors_ids[appointment.start_date] << appointment_proposal_info.doctor.profile
                            t(:p, {}, "#{appointment_proposal_info.doctor.profile.name}: #{Moment.new(appointment_proposal_info.date_from).format('HH:mm')} - #{Moment.new(appointment_proposal_info.date_to).format('HH:mm')}")
                          end
                        )
                      end
                    ),
                    t(:td, {}, 
                      t(:button, { onClick: ->{ open_appointment_schedulers_index(appointment) } }, 'browse availability')
                    ),
                    t(:td, {}, 
                      t(:button, { onClick: ->{ init_new_from_proposal(appointment, Moment.new(appointment.start_date).startOf('day')) } }, 'schedule')
                    ),
                    t(:td, {}, 
                      t(:button, { onClick: ->{ delete_an_appointment(appointment) } }, 'delete')
                    )
                  )
                end
              )
            )
          ) 
        end

        def init_new_from_proposal(appointment, date)
          modal_open(
            'schedule',
            t(Components::Appointments::AppointmentSchedulers::NewFromProposal, {date: date, appointment: appointment} )
          )
        end

        def open_appointment_schedulers_index(appointment)
          start_date = appointment.start_date
          uniq_profiles = {}
          @dates_and_doctors_ids[start_date].each do |profile|
            uniq_profiles[profile.user_id] = profile unless uniq_profiles[profile.id]
          end
          modal_open(
            "browse",
            t(Components::Appointments::AppointmentSchedulers::Index, {date: start_date, uniq_profiles: uniq_profiles, 
                                                                      appointment: appointment, from_proposal: true} )
          )
        end

        def delete_an_appointment(appointment)

          appointment.destroy(namespace: 'doctor').then do |_appointment|
            appointment_to_remove = state.appointments.where do |ap|
              next unless ap
              ap.id == _appointment.id
            end

            state.appointments.remove(appointment_to_remove[0])

            set_state appointments: state.appointments

          end

        end

        def delete_unregistered_users_with_proposals(patient)
          patient.destroy_unregistered_user_with_proposals.then do |patient|
            component_did_mount
          end
        end

      end
    end
  end
end

