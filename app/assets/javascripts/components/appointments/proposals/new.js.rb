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
          @blank_appointment_detail = ->{AppointmentDetail.new(proposal_info: {
                                          primary_preferred: {},
                                          optionally_preferred: {}
                                        })}
          @blank_appointment = ->{Appointment.new(appointment_detail: @blank_appointment_detail.call)}
         {
            form_model: @blank_appointment.call
          }
        end

        def render

          t(:div, {},
            t(:div, {},
              *splat_each(props.appointment_availabilities) do |k, v|
                t(:span, {},
                  "#{k}",
                  t(:br, {}),
                  *splat_each(v[0].map) do |av|
                    t(:div, {},
                      t(:span, {}, "#{av[0].format('HH:mm')} - #{av[1].format('HH:mm')}", t(:br, {})),
                      input(Forms::PushCheckBox, state.form_model.appointment_detail, :proposal_info, 
                        {checked: false, push_value: {primary_preferred: {1 => [av[0].format, av[1].format]}}.block_to_n}
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
          p state.form_model.pure_attributes
          set_state form_model: @blank_appointment.call
        end

      end
    end
  end
end
