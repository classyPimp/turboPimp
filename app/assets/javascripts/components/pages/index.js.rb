module Components
  module Pages
    class Index < RW
      expose

      include Plugins::Paginatable

      def assign_controller
        @controller = PagesController.new(self)
      end

      def get_initial_state
        {
          pages: ModelCollection.new
        }
      end

      def component_did_mount
        Page.index.then do |pages|
          extract_pagination(pages)
          #p pages.pure_attributes
          set_state pages: pages
        end.fail do |pr|
          `console.log(#{pr})`
        end
      end

      def render
        t(:div,{},
          *splat_each(state.pages) do |page|
            t(:div, {key: "#{page}"},
              t(:p, {}, "metas: m_title: #{page.m_title}, m_description: #{page.m_description}, m_keywords: #{page.m_keywords}"),
              t(:p, {}, "title: #{page.title}"),
              t(:div, {dangerouslySetInnerHTML: {__html: page.body}}),
              t(:button, {}, link_to("edit this page", "/pages/edit/#{page.id}")),
              link_to("show this page", "/pages/show/#{page.slug}"),
              t(:button, {onClick: ->(){@controller.destroy(page)}}, "destroy this page")
            )
          end,
          will_paginate,
          t(:br, {})
        )
      end

      def pagination_switch_page(_page)
        Page.index({},{extra_params: {page: _page}}).then do |pages|
          extract_pagination(pages)
          set_state pages: pages
        end
      end

      


    end
  end 
end