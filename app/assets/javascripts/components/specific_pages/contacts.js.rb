module Components
  module SpecificPages
    class Contacts < RW
      expose

      def get_initial_state
        {
          page: false
        }
      end

      def component_did_mount
        Page.show(wilds: {id: 'contacts'}).then do |page|
          set_state page: page
        end
        el = Element.find(ref(:map_embed).to_n)
        el.html = '<iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2905.8966068706877!2d76.92578854289161!3d43.25358868524766!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x38836eb72522ceb1%3A0xbdd6c324052ca884!2sTole+Bi+St+96%2C+Almaty!5e0!3m2!1sen!2skz!4v1454927415870" width="600" height="450" frameborder="0" style="border:0" allowfullscreen></iframe>'
      end

      def render
        t(:div, {},
          t(:div, {className: 'row'},
            t(:div, {className: 'col-lg-3'}),
            t(:div, {className: 'col-lg-6'},
              t(:div, {className: 'row'},
                if state.page
                  t(:div, {dangerouslySetInnerHTML: {__html: state.page.body}.to_n})
                end
              ),
              t(:div, {className: 'row'},
                t(:div, {ref: "map_embed"})
              )
            ),
            t(:div, {className: 'col-lg-3'}),
          )         
        )
      end

    end
  end
end