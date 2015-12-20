module Components
  module Blogger
    module Blogs
      class Dashboard < RW
        expose


        def render
          t(:div, {},
            t(:h3, {}, "last ten blogs by me"),
            t(Components::Blogger::Blogs::LastTen, {}),
            t(Components::Blogger::Blogs::Index, {})
          )
        end
      end
    end
  end
end