module Components
  module AppointmentSchedulers
    module ChatMessages
      class Index < RW
        expose

        def component_did_mount
          ChatMessage.index(namespace: 'appointment_scheduler').then do |users|
            
          end
        end

        def render
          t(:div, {},

          )
        end

      end
    end
  end
end