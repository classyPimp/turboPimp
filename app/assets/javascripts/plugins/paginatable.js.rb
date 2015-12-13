module Plugins
  #this plugin provides easy integration with will_paginate on Rails
  #be warned that your base should implement the #pagination_switch_page which
  #has to make a request with query string containing the page=<page arg>
  module Paginatable

    #Rails needs to append pagination info at last index of collection in following format:
    #as if pagination was model
    #example of your controller returning with will_paginate

    #def index
    #  if params[:search_query].present?
    #   @images = Image.search_by_alt_description(params[:search_query])
    # else
    #   @images = Image.all
    # end
    # @images = @images.paginate(page: params[:page], per_page: 2)
    # render json: @images.as_json(only: [:id, :alt, :description], methods: [:url]) << 
    #                      {pagination: {current_page: @images.current_page, total_entries: @images.total_entries, total_pages: @images.total_pages,
    #                      offset: @images.offset}}
    #end

    #also define a pagination model for easy managing
    #front_models/pagination:

  #class Pagination < Model
  #
  #  attributes :current_page, :total_entries, :total_pages, :next_page, :previous_page, :offest
  #end 

    #if do it like that you'll be able to extract pagination instance via this method
    #example usage in RW component:

  #include Plugins::Paginatable
  #def component_did_mount
  #  Image.index.then do |images|
  #    extract_pagination(images) <=========
  #    set_state images: images
  #    p "set_state"
  #  end.fail do |pr|
  #    `console.log(#{pr})`
  # end
  #end
  #his will set state.pagination to your extracted pagination
  #nd will make will_paginate element render proper values

    def extract_pagination(collection)
      if x = (collection.data.pop if collection[-1].instance_of? Pagination)
        self.state.pagination = x
      end
    end
    #this method will return an element containing pagination controls
    #or nil if state.pagination is not set
    #just call it in render as regular #t
    #used after pagination was extracted from response

    def will_paginate
      t(:nav, {},
        *if p_n = state.pagination
          t(:ul, {className: "pagination", style: {cursor: "pointer"}}, 
            t(:li, {className: x = "#{p_n.current_page == 1 ? "disabled" : ""}", style: {cursor: "pointer"}},
              t(:a, {}.merge(x == '' ? {onClick: ->{pagination_switch_page(p_n.current_page - 1)}} : {}), "<<")
            ),         
            *(to_return = [] 
            p_n.total_pages.times do |page|
              page += 1
              if page == p_n.current_page
                to_add  = t(:li, {className: "active"}, 
                            t(:span, {}, "#{page}")
                          )
              else
                to_add = t(:li, {onClick: ->(){pagination_switch_page(page)}},
                  t(:span, {}, "#{page}")
                )
              end
              to_return << to_add
            end
            to_return),            
            t(:li, {className: x = "#{p_n.current_page == p_n.total_pages ? 'disabled' : ''}", style: {cursor: "pointer"} }, 
              t(:span, {}.merge(x == '' ? {onClick: ->{pagination_switch_page(p_n.current_page + 1)}} : {}), ">>")
            )
          )
        end
      )
    end
    #your RW component must implement this method
    #basically it's goal is to send request with query of ?page=(page arg)
    #and to handle a response
    #example implementation
  #def pagination_switch_page(page)
  #  ::App.history.replaceState(nil, "#{props.location.pathname}?page=#{page}")
  #  Image.index({},{extra_params: {page: page}}).then do |images|
  #    extract_pagination(images)
  #    set_state images: images
  #  end
  #end
  #as well you can make it dependent to load on query params to be indexable

    def pagination_switch_page(page)
      raise "#{self} must implement #pagination_switch_page(page) refer to #{self.class} for info"
    end

  end
end