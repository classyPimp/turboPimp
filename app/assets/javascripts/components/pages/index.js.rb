module Components
  module Pages
    class Index < RW
      expose

      include Plugins::Paginatable

      def assign_controller
        @controller = PagesController.new(self)
      end

      def initial_state
        {
          pages: ModelCollection.new
        }
      end

      def component_did_mount
        Page.index.then do |pages|
          extract_pagination(pages)
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
              t(:button, {}, link_to("edit this page", "/pages/edit/#{page.id}"))
              #t(:button, {onClick: ->(){init_page_edit(page)}}, "edit this page"),
              #t(:button, {onClick: ->(){destroy(page)}}, "destroy this page")
              #t(:button, {onCLick: ->(){show(page)}})
            )
          end,
          will_paginate,
          t(:br, {}),
          #t(PageCreate, {on_create: ->(page){add_page(page)}}),
          #t(PageEdit, {on_edit_done: ->(page){update_page(page)}, ref: "page_edit_form"})
        )
      end

      def pagination_switch_page(_page)
        Page.index({},{extra_params: {page: _page}}).then do |pages|
          extract_pagination(pages)
          set_state pages: pages
        end
      end

      def destroy(page)
        page.destroy.then do |r|
          state.pages.remove(page)
          set_state pages: state.pages
        end
      end

      def init_page_edit(page)
        ref(:page_edit_form).__opalInstance.init_page_edit(page)
      end

      def add_page(page)
        (state.pages << page)
        set_state pages: state.pages
      end

      def update_page(page)
        set_state pages: state.pages
      end
    end
  end 
end