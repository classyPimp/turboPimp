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
            t(:h1, {className: 'top_title'}, 'My last ten blogs'),
            *splat_each(state.blogs) do |blog|
              t(:div, {className: 'blogger_last_ten'},
                t(:h3, {className: 'title'}, link_to("#{blog.title}", "/blogs/edit/#{blog.id}")),
                t(:p, {}, "created: #{Moment.new(blog.attributes[:created_at]).format('YYYY.MM.DD')}"),
                t(:div, {className: 'body', dangerouslySetInnerHTML: {__html: blog.body}.to_n})
              )
            end
          )
        end

      end
    end
  end
end