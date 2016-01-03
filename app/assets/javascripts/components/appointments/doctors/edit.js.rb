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
            appointment.attributes[:start_date_s] = state.parsed_start.format('YYYY-MM-DDTHH:mm')
            appointment.attributes[:end_date_s] = state.parsed_end.format('YYYY-MM-DDTHH:mm')
            set_state form_model: appointment
          end
        end

        def render
          t(:div, {},
            spinner,
            if state.form_model
              t(:div, {},
                input(Forms::Input, state.form_model, :date_part, {type: "hidden", comp_options: {style: {display: "none"}}}),
                input(Forms::Input, state.form_model, :start_date_s),
                input(Forms::Input, state.form_model, :end_date_s),
                input(Forms::Select, state.form_model, :patient_id, {
                      server_feed: {url: "/api/patients/patients_feed"}, 
                      s_value: "user_id",
                      s_show: "name"}),
                input(Forms::Textarea, state.form_model.appointment_detail, :note),
                t(:br, {}),
                t(:button, {onClick: ->{handle_inputs}}, "submit")
              )
            end
          )
        end

        def handle_inputs
          collect_inputs
          m_a = state.form_model.attributes
          state.form_model.start_date = Moment.new(m_a[:start_date_s]).format()
          state.form_model.end_date = Moment.new(m_a[:end_date_s]).format()
          state.form_model.validate
          unless state.form_model.has_errors?
            state.form_model.update(namespace: "doctor").then do |model|
              if model.has_errors?
                set_state form_model: model
              else
                begin
                props.passed_appointment.attributes = model.attributes
                props.on_appointment_updated(props.passed_appointment)
                alert "updated successfully!"
              rescue Exception => e
                p e
              end
              end
            end
          else
            set_state form_model: state.form_model
          end
        end

      end
    end
  end
end