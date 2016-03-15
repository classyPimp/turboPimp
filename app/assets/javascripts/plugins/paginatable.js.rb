module Plugins
  #this plugin provides easy integration with will_paginate on Rails

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

    #also there is defined pagination model for easy managing
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
  #and will make will_paginate element render proper values
  # #
  #     paginatable supports two patterns of fetching resources corresponding to page
  #     non url based where resource is fetched via #pagination_switch_page(page_number : String, event)
  #     where event should be prevented and resource fetched manually
  #     and #on_per_page_select should also handle per_page value

  #     AND 

  #     url based fetching where page is link_to, and component listents to #component_will_recieve_props(next_props)
  #     where it compares props.location.query and if different will fetch corresponding resource


  # FOR NON URL BASED state.non_url_pagination should be set to true
  # and state.pagination_per_page should keep the number of per_page as well component should manually handle those.

  # EXAMPLE FOR NON URL

  #     def pagination_switch_page(page, event)
  #       `#{event}.preventDefault()`
  #       #Components::App::Router.history.pushState(nil, "#{props.location.pathname}?page=#{page}")
  #       query = state.search_query
  #       query[:page] = page
  #       make_query(query)
  #     end

  #     def per_page_select(per_page_num)
  #       query = state.search_query
  #       query[:per_page] = per_page_num
  #       query[:page] = 1
  #       make_query(query)
  #     end
  # where #make_query has e.g. model.index(extra_params: query)

    def extract_pagination(collection)
      if x = (collection.data.pop if collection[-1].instance_of? Pagination)
        self.state.pagination = x
      end
    end
    #this method will return an element containing pagination controls
    #or nil if state.pagination is not set
    #just call it in render as regular #t
    #used after pagination was extracted from response

    def href_for_page(page)
      #for components that do not depend on url change for pagination switch page
      #state.non_url_pagination shall be defined
      #moreover if such defined, please provide #paginaition_switch_page(page_num, event)
      #that prevents the passed events and fetches resource manually
      if !state.non_url_pagination
        href = Hash.new(props.location.query.to_n)
        href[:page] = page
        href[:per_page] = current_per_page
        href = props.history.createHref(props.location.pathname, href)
      else
        href = '#'
      end
    end

    def current_per_page
      if !state.non_url_pagination
        props.location.query.per_page
      else
        state.pagination_per_page
      end
    end

    # def prev_next(direction)
    #   @per_page = props.location.query.per_page || 1
    #   prev_query = Hash.new(props.location.query.to_n)
    #   prev_query[:page] = state.pagination.current_page - 1
    #   prev_query[:per_page] = @per_page
    #   @_previous_page_href = props.history.createHref(props.location.pathname, prev_query)
    #   next_query = prev_query.clone
    #   next_query[:page] = prev_query[:page] + 2
    #   next_query[:per_page] = @per_page
    #   @_next_page_href = props.history.createHref(props.location.pathname, next_query)
    # end

    # def per_page
    #   @per_page = props.location.query.per_page || 1
    # end

    def will_paginate

      if state.pagination
        cur_p = state.pagination.current_page
      end
      
      t(:div, {className: 'pagination_main'},    
        *if p_n = state.pagination
          t(:nav, {},
            t(:ul, {className: "pagination", style: {cursor: "pointer"}.to_n}, 
              t(:li, {className: x = "#{p_n.current_page == 1 ? "disabled" : ""}", 
                      style: {cursor: "pointer"}.to_n},
                unless x == "disabled"
                  link_to('<<', href_for_page(cur_p - 1), {}, onClick: ->(e){pagination_switch_page((cur_p - 1), e)}) 
                end
              ),         
              *(to_return = [] 
              p_n.total_pages.times do |page|
                page += 1
                if page == p_n.current_page
                  to_add  = t(:li, {className: "active"}, 
                              t(:span, {}, "#{page}")
                            )
                else
                  to_add = t(:li, {},
                    #t(:span, {}, "#{page}")
                    link_to(page, href_for_page(page), {}, onClick: ->(e){pagination_switch_page(page, e)})
                  )
                end
                to_return << to_add
              end
              to_return),            
              t(:li, {className: x = "#{p_n.current_page == p_n.total_pages ? 'disabled' : ''}",
                      style: {cursor: "pointer"} },
                unless x == "disabled"
                  link_to('>>', href_for_page(cur_p + 1), {}, onClick: ->(e){pagination_switch_page((cur_p + 1), e)}) 
                end
              ),
              t(:li, {},
                t(:span, {},
                  "per page", 
                  t(:select, {ref: "pagination_select", onChange: ->(e){per_page_select(`#{e}.target.value`)}, value: "#{current_per_page}"},
                    t(:option, {value: '1'}, '1'),
                    t(:option, {value: '25'}, "25"),
                    t(:option, {value: '50'}, "50"),
                    t(:option, {value: '100'}, "100"),
                    t(:option, {value: '200'}, "200")
                  )
                )
              )
            ),
            
          )
        end
      )
      
      
      
    end


    # def add_option(value)
    #   if value == state.per_page.to_i
    #     o = {value: value, selected: 'true'}
    #   else
    #     o = {value: value}
    #   end
    #   t(:option, o, "#{}")
    # end
    
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
    # def _per_page_select
    #   _per_page = self.ref(:pagination_select).value
    #   @per_page = _per_page
    #   on_per_page_select(@_per_page)
    # end

    def pagination_switch_page(page, event)
      raise "#{self} must implement #pagination_switch_page(page, per_page) refer to #{self.class} for info"
    end

    def on_per_page_select(p_p)
      raise "#{self} must implement #on_per_page_select(per_page) refer to #{self.class} for info"
    end

  end
end