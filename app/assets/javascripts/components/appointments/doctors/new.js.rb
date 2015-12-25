module Components
  module Appointments
    module Doctors
      class New < RW
        expose

        include Plugins::Formable

        def get_initial_state
          {
            form_model: Appointment.new
          }
        end

        def render
          t(:div, {},
            input(Forms::Input, state.form_model, :start, {type: "datetime-local"})
          )
        end

      end
    end
  end
end