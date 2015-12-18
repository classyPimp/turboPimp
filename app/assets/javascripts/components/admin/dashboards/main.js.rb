module Components
  module Admin
    module Dashboards
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
end