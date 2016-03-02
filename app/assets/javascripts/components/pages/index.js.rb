module Components
  module Pages
    class Index < RW
      expose

      include Plugins::Paginatable

      def assign_controller
        @controller = PagesController.new(self)  
      end

      def init
        @namespace = {}
        if props.as_admin
          @namespace = {namespace: "admin"}
        end
      end
  
      def get_initial_state
        {
          pages: ModelCollection.new
        }
      end

      def component_did_mount
        extra_params = {}
        (x = props.location.query.page) ? (extra_params[:page] = x) : nil
        extra_params[:per_page] = (x = props.location.query.per_page) ? x : 25
        extra_params[:search_query] = (x = props.location.query.search_query) ? x : nil
        make_query(extra_params) 
      end

      def make_query(extra_params)
        Page.index({component: self, extra_params: extra_params}.merge(@namespace)).then do |pages|
          extract_pagination(pages)
          set_state pages: pages
        end
      end

      def render
        t(:div,{},
          spinner,
          t(:div, {},
            t(:input, {ref: "search"}),
            t(:button, {onClick: ->{search}}, "search!")
          ),
          *splat_each(state.pages) do |page|
            t(:div, {key: "#{page}"},
              t(:p, {}, "metas: m_title: #{page.m_title}, m_description: #{page.m_description}, m_keywords: #{page.m_keywords}"),
              t(:p, {}, "title: #{page.title}"),
              if props.as_admin
                t(:div, {},
                  t(:button, {onClick: ->{destroy_page(page)}}, "delete this page"),
                  t(:button, {}, link_to("edit", "/pages/#{page.id}/edit"))
                ) 
              end,
              t(:div, {dangerouslySetInnerHTML: {__html: page.body}.to_n, style: {height: "150px", overflow: "scroll"}.to_n }),
              link_to("show this page", "/pages/show/#{page.slug}")
            )
          end,
          will_paginate(true),
          t(:br, {})
        )
      end

      def pagination_switch_page(_page, per_page)
        Page.index({extra_params: {page: _page, per_page: per_page, search_query: props.location.query.search_query}}.merge(@namespace)).then do |pages|
          Components::App::Router.history.replaceState(nil, props.location.pathname, {page: _page, per_page: per_page})
          extract_pagination(pages)
          set_state pages: pages
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

      #*//////////////********** AS_ADMIN
      def component_will_unmount
        Components::App::Main.instance.props.history.replaceState(nil, Components::App::Main.instance.props.location.pathname, {})
      end

      def destroy_page(page)
        page.destroy.then do |_page|
          state.pages.remove(page)
          set_state pages: state.pages
        end
      end

      #*************************** END AS ADMIN

    end
  end 
end