module Components
  module Shared
    module Doctors
      class GroupList < RW
        expose

        def get_initial_state
          doctors: ModelCollection.new
        end

        def render
          t(:div, {},
            t(:h4, {}, 'our doctors:'),
            spinner, 
            t(:ul, {className: 'grup-list'}, 

            )
          ) 
        end

        def component_did_mount
          User.index(namespace: 'doctors').then do |doctors|
            set_state doctors: doctors
          end
        end

      end
    end
  end
end