module Components
  module Blogs
    class Index < RW 

      expose

      include Plugins::Paginatable
      include Plugins::DependsOnCurrentUser

      set_roles_to_fetch :blogger

      def init
        @namespace = {}
        if CurrentUser.user_instance.has_role?([:blogger])
          @namespace = {namespace: "blogger"}
        end
      end

      def get_initial_state
        {
          blogs: ModelCollection.new,
          pagination_per_page: 1
        }
      end

      def component_did_mount
        x = Hash.new(props.location.query.to_n)
        unless x.empty?
          make_query(x)
        end
      end

      def component_will_receive_props(next_props)
        n_q = Hash.new(Native(next_props).location.query.to_n)
        c_q = Hash.new(props.location.query.to_n)  
        if n_q != c_q
          make_query(n_q)
        end      
      end

      def make_query(_extra_params)
        #_extra_params[:per_page] = _extra_params[:per_page] || props.location.query.per_page || 1
        Blog.index({component: self, extra_params: _extra_params}.merge(@namespace)).then do |blogs|
          extract_pagination(blogs)
          set_state blogs: blogs, pagination_per_page: _extra_params[:per_page]
        end
      end

      def render
        t(:div,{},
          spinner,
          t(:div, {},
            t(:input, {ref: "search"}),
            t(:button, {onClick: ->{search}}, "search!")
          ),
          *splat_each(state.blogs) do |blog|
            t(:div, {key: "#{blog}"},
              t(:p, {}, "metas: m_title: #{blog.m_title}, m_description: #{blog.m_description}, m_keywords: #{blog.m_keywords}"),
              t(:p, {}, "title: #{blog.title}"),
              if blog.attributes[:author].is_a? Model
                t(:p, {}, "author: #{blog.attributes[:author].name}")
              end,
              if CurrentUser.user_instance.has_role?([:blogger])
                t(:div, {},
                  if blog.published
                    t(:button, {onClick: ->{toggle_publish(blog)}}, "upublish")
                  else
                    t(:button, {onClick: ->{toggle_publish(blog)}}, "publish")
                  end,
                  t(:button, {onClick: ->{destroy_blog(blog)}}, "delete this blog post"),
                  t(:button, {}, link_to("edit", "/blogs/#{blog.id}/edit"))
                ) 
              end,
              t(:div, {dangerouslySetInnerHTML: {__html: blog.body}.to_n}),
              link_to("show this blog", "/blogs/show/#{blog.slug}")
            )
          end,
          will_paginate,
          t(:br, {})
        )
      end

      def pagination_switch_page(_page, per_page)
        # Blog.index({extra_params: {page: _page, per_page: per_page}}.merge(@namespace)).then do |blogs|
        #   Components::App::Router.history.replaceState(nil, props.location.pathname, {page: _page, per_page: per_page})
        #   extract_pagination(blogs)
        #   set_state blogs: blogs
        # end
      end

      def search
        to_search = self.ref("search").value.strip
        pathname = props.location.pathname
        query = Hash.new(props.location.query.to_n)
        query[:search_query] = to_search
        query[:page] = 1
        query[:per_page] = state.pagination_per_page
        props.history.pushState(nil, pathname, query)
      end

      def per_page_select(value) #from Plugins::Paginatable
        c_q = Hash.new(props.location.query.to_n)
        c_q[:per_page] = value
        c_q[:page] = 1
        props.history.pushState(nil, props.location.pathname, c_q)
      end

      #*//////////////********** AS_BLOGGER
      def component_will_unmount
        Components::App::Main.instance.props.history.replaceState(nil, Components::App::Main.instance.props.location.pathname, {})
      end

      def toggle_publish(blog)
        blog.toggle_published(namespace: "blogger").then do |_blog|
          blog.update_attributes(_blog.attributes)
          set_state blogs: state.blogs
        end
      end

      def destroy_blog(blog)
        blog.destroy.then do |_blog|
          state.blogs.remove(blog)
          set_state blogs: state.blogs
        end
      end

      #*************************** END AS BLOGGER

    end
  end
end