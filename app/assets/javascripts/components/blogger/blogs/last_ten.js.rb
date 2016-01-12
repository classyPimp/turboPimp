module Components
  module Blogger
    module Blogs
      class LastTen < RW
        expose

        def get_initial_state
          {
            blogs: ModelCollection.new
          }
        end

        def component_did_mount
          Blog.last_ten(namespace: "blogger", component: self).then do |blogs|
            set_state blogs: blogs
          end
        end

        def render
          t(:div, {},
            spinner,
            *splat_each(state.blogs) do |blog|
              t(:div, {},
                t(:p, {}, link_to("#{blog.title}", "/blogs/edit/#{blog.id}")),
                t(:hr, {style: {color: "grey", height: "1px", backgroundColor: "black"}.to_n})
              )
            end
          )
        end

      end
    end
  end
end