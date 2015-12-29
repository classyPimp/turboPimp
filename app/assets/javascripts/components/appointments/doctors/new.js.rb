module Components
  module Appointments
    module Doctors
      class New < RW
        expose

        include Plugins::Formable

        #PROPS
        #date: date that will be passed and assigned to form model


        def get_initial_state
          {
            form_model: Appointment.new(date_part: props.date.format("YYYY-MM-DD"),
              appointment_detail: {appointment_detail: {}}
              ) 
          }
        end

        def render
          t(:div, {},
            input(Forms::Input, state.form_model, :date_part, {type: "hidden", comp_options: {style: {display: "none"}}}),
            "#{props.date.format('YYYY-MM-DD')}",
            input(Forms::Input, state.form_model, :time_part_from, {input_props: {placeholder: "HH:MM"}}),
            input(Forms::Input, state.form_model, :time_part_to, {input_props: {placeholder: "HH:MM"}}),
            input(Forms::Select, state.form_model, :patient_id, {
                  server_feed: {url: "/api/patients/patients_feed"}, 
                  serialize_value: {model_name: "profile", value_attr: "name"},
                  select_only_attr: "user_id"}),
            input(Forms::Textarea, state.form_model.appointment_detail, :note),
            t(:button, {onClick: ->{handle_inputs}}, "submit")
          )
        end

        def handle_inputs
          collect_inputs
          m_a = state.form_model.attributes
          start_str = "#{m_a[:date_part]}T#{m_a.delete(:time_part_from)}"
          end_str = "#{m_a.delete(:date_part)}T#{m_a.delete(:time_part_to)}"
          state.form_model.start_date = Moment.new(start_str).format()
          state.form_model.end_date = Moment.new(end_str).format()
          unless state.form_model.has_errors?
            state.form_model.create(namespace: "doctor").then do |model|
              if model.has_errors?
                set_state form_model: model
              else
                state.form_model = model
                props.on_appointment_created(model)
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
