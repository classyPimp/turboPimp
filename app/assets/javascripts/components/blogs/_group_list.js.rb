module Components
  module Blogs
    class GroupList < RW
      expose

      def get_initial_state
        {
          blogs: ModelCollection.new
        }
      end

      def component_did_mount
        Blog.index_for_group_list.then do |blogs|
          begin
          p blogs
          set_state blogs: blogs
        rescue Exception => e
          p e
        end
        end
      end

      def render
        t(:div, {className: 'list-group'},
          t(:p, {className: 'list-group-item'}, 
            'latest blogs'
          ), 
          *splat_each(state.blogs) do |blog|
            t(:div, {className: 'list-group-item'}, 
              t(:p, {}, 
                t(:span, {}, 
                  t(:image, {src: blog.user.avatar.url, style: {hight: '50px', width: '50px'}.to_n}),
                  t(:span, {}, blog.user.profile.name)
                )
              ),
              t(:p, {}, blog.title),
              t(:div, {dangerouslySetInnerHTML: {__html: blog.body}.to_n, style: {overflow: 'ellipsis'}}, 
              )
            )
          end
        )
      end

    end
  end
end
