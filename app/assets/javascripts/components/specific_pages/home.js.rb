module Components
  module SpecificPages
    class Home < RW

      expose

      def render
        t(:div, {}, 
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
          ),
          t(Components::Layouts::EightFour, 
            {
              eight: 
              [
                t(Components::Pages::Show, {page_id: 'about-us'})
              ],
              four: 
              [
                t(:div, {className: 'sidebar'},
                  t(Components::Partials::Doctors::ListGroup, {}),
                  t(Components::Blogs::GroupList, {})
                )
              ]
            }
          )
        )
      end

    end
  end
end
