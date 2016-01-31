module Components
  module SpecificPages
    class Home < RW

      expose

      def render
        t(:div, {className: 'jumbotron'}, 
          t(:div, {className: 'container text-center'}, 
            t(:div, {className: 'row'}, 
              t(:div, {className: 'col-lg-6'}, 
                t(:h1, {}, 
                  "ABC dent"
                ),
                t(:h4, {}, 
                  "the family dental clinic you'll like"
                )
              ),
              t(:div, {className: 'col-lg-6'}, 
                t(:h5, {}, 
                  'Astana, XX Bognebay ave.'
                )
              )
            )
          )
        )
      end

    end
  end
end
