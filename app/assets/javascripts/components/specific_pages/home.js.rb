module Components
  module SpecificPages
    class Home < RW

      expose

      def render
        t(:div, {className: 'row'}, 
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
          t(:div, {className: 'row below_jumbo', ref: 'row_below', id: 'element-waypoint'}, 
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
          ),
          t(:button, {onClick: ->{unlist}}, 'unlisten')
        )
      end

      class Waypoint

        def initialize(opt)
          `console.log(#{opt})`
          @native = Native(`new Waypoint(#{opt.to_n})`)
        end

        def destroy
          @native.destroy
        end

      end


      def component_did_mount
        p 'did mount'
        
        @wayp = Element.find('.below_jumbo')
        @wy  = Waypoint.new(
          {
            element: @wayp,
            handler: ->(direction){ p('foo') },
            offset: '10%'
          }
        )
        # @wy = %x{
        #   waypoint = new Waypoint({
        #     element: #{@wayp.to_n},
        #     handler: function(direction) {
        #       console.log('I am still alive')
        #     },
        #     offset: '10%'
        #   })
        # }
        p 'foo'
      end

      def unlist
        p 'foo'
        @wy.destroy
        p 'foo'
      end

    end
  end
end
