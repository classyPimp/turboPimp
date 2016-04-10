module Components
  module Layouts
    class EightFour < RW
      expose

      def render
        t(:div, {className: 'row'}, 
          t(:div, {className: 'col-lg-8 text-justify'}, 
            *splat_each(props.eight) do |component|
              component
            end
          ),
          t(:div, {className: 'col-lg-4'},
            t(:div, {className: 'well bg-info text-center', style: {background: '#C2DFF3'}.to_n}, 
              *splat_each(props.four) do |component|
                component
              end
            ) 
          ),
          t(Shared::Footer, {on_home_route: true})
        )
      end

    end
  end
end