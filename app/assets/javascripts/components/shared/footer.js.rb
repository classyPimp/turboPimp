module Shared
  class Footer < RW

    expose

    def init
      @class_to_add = nil
      if props.on_home_route
        @class_to_add = 'home_footer'
      end
    end
    
    def render
      t(:footer, {className: "footer row #{@class_to_add}"}, 
        t(:div, {className: 'g_adress_bar', itemscope: '', itemtype: "http://schema.org/LocalBusiness"}, 
          t(:p, {itemprop: 'name'}, 
            'ABC stom'
          ),
          t(:p, {itemprop: 'adress', itemscope: '', itemtype: "http://schema.org/PostalAddress"}),
          t(:p, {itemprop: 'streetAddress'}, 
            'Kabanbay batyr ave, 77'
          ),
          t(:p, {itemprop: "addressLocality"}, 
            'Astana'
          ),
          t(:p, {itemprop: "addressRegion"}, 
            'Kazakhstan'
          ),
          t(:P, {itemprop: "postalCode"}, 
            '010000'
          ),
          t(:p, {itemprop: "telephone"}, 
            '+7 7172 55-46-83'
          ),
          t(:meta, {itemprop: "latitude", content: "LATITUDE"}),
          t(:meta, {itemprop: "longtitude", content: "LATITUDE"})
        )
      )        
    end

  end
end
