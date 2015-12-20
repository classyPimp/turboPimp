module Components
  module Blogger
    module Blogs
      class Index < RW
        expose

      include Plugins::Paginatable

      def get_initial_state
        {
          blogs: ModelCollection.new
        }
      end

      def component_will_mount
        extra_params = {}
        (x = props.location.query.page) ? (extra_params[:page] = x) : nil
        extra_params[:per_page] = (x = props.location.query.per_page) ? x : 25
        extra_params[:search_query] = (x = props.location.query.search_query) ? x : nil
        make_query(extra_params) 
      end

      def make_query(extra_params)
        Blog.index(component: self, extra_params: extra_params).then do |blogs|
          extract_pagination(blogs)
          #p pages.pure_attributes
          set_state blogs: blogs
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
              t(:div, {dangerouslySetInnerHTML: {__html: blog.body}}),
              link_to("show this blog", "/blogs/show/#{blog.slug}")
            )
          end,
          will_paginate(true),
          t(:br, {})
        )
      end

      def pagination_switch_page(_page, per_page)
        Blog.index(extra_params: {page: _page, per_page: per_page}).then do |blogs|
          Components::App::Router.history.replaceState(nil, props.location.pathname, {page: _page, per_page: per_page})
          extract_pagination(blogs)
          set_state blogs: blogs
        end
      end

      def search
        to_search = self.ref("search").value.strip
        pathname = props.location.pathname
        query = Hash.new(props.location.query.to_n)
        query[:search_query] = to_search
        query
        make_query(query)
        props.history.pushState(nil, pathname, query)
      end

      end
    end
  end
end