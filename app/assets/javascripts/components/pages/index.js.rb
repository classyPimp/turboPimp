module Components
  module Pages
    class Index < RW
      expose

      def initial_state
        {
          pages: ModelCollection.new
        }
      end

      def component_did_mount
        Page.index.then do |pages|
          if x = (pages.data.pop if pages[-1].instance_of? Pagination)
            self.state.pagination = x
          end
          set_state pages: pages
        end.fail do |pr|
          `console.log(#{pr})`
        end
      end

      def render
        t(:div,{},
          *splat_each(state.pages) do |page|
            t(:div, {key: "#{page}"},
              t(:p, {}, "body: #{page.body}"),
              t(:p, {}, "text: #{page.text}"),
              t(:button, {onClick: ->(){init_page_edit(page)}}, "edit this page"),
              t(:button, {onClick: ->(){destroy(page)}}, "destroy this page")
              #t(:button, {onCLick: ->(){show(page)}})
            )
          end,
          t(:div, {className: "pagination"},
            *if state.pagination
              will_paginate
            end
          ),
          t(:br, {}),
          t(PageCreate, {on_create: ->(page){add_page(page)}}),
          t(PageEdit, {on_edit_done: ->(page){update_page(page)}, ref: "page_edit_form"})
        )
      end

      def will_paginate

        to_ret = []
        state.pagination.total_pages.times do |pa|
          pa += 1
          if pa == state.pagination.current_page
            to_add  = t(:span, {}, "#{pa} - current_page")
          else
            to_add = t(:a, {onClick: ->(){jump_to(pa)}}, "\t#{pa}\t")
          end
          to_ret << to_add
        end
        to_ret
      end

      def jump_to(pa)
        Page.index({},{extra_params: {page: pa}}).then do |pages|
          if x = (pages.data.pop if pages[-1].instance_of? Pagination)
            self.state.pagination = x
          end
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