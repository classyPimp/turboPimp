module Components
  module Appointments
    module Doctors
      class Edit < RW
        expose

        include Plugins::Formable

        def get_initial_state
          {
            form_model: false
          }
        end

        def component_did_mount
          Appointment.edit(wilds: {id: props.id}, namespace: "doctor", component: self).then do |appointment|     
            state.parsed_start = Moment.new appointment.start_date
            state.parsed_end = Moment.new appointment.end_date
            appointment.attributes[:start_date_s] = state.parsed_start.format('MM-DDTHH:mm')
            appointment.attributes[:end_date_s] = state.parsed_end.format('MM-DDTHH:mm')
            set_state form_model: appointment
          end
        end

        def render
          t(:div, {},
            spinner,
            if state.form_model
              t(:div, {},
                # input(Forms::Input, state.form_model, :date_part, {type: "hidden", comp_options: {style: {display: "none"}}}),
                # input(Forms::Input, state.form_model, :start_date_s),
                # input(Forms::Input, state.form_model, :end_date_s),
                input(Forms::Select, state.form_model, :patient_id, {
                      server_feed: {url: "/api/patients/patients_feed"}, 
                      s_value: "user_id",
                      s_show: "name"}),
                # input(Forms::Textarea, state.form_model.appointment_detail, :note),
                t(:br, {}),
                t(:button, {onClick: ->{handle_inputs}}, "submit")
              )
            end
          )
        end

      end
    end
  end
end