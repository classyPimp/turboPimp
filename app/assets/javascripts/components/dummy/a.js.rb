module Components
  module Dummy
    class A < RW
      expose

      

      def render
        t(:div, {}, 
          t(Shared::ProgressBar, {ref: 'prog'}),
          t(:button, {onClick: ->{ ref(:prog).rb.on} }, 'start'),
          t(:button, {onClick: ->{ ref(:prog).rb.off }}, 'finish')

        )
        
      end

    end
  end
end
