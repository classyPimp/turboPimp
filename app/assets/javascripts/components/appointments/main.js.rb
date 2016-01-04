module Components
  module Appointments
    class Main < RW
      expose

      def render
        t(:div, {},
          children
        ) 
      end

    end
  end
end