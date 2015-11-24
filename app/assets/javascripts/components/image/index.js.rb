module Components
	module Images
		class Index < RW
			expose

			def initial_state
		    {
		      images: ModelAssociation.new,
          query: ""
		    }
		  end

		  def component_did_mount
		    Image.index().then do |images|
		      if x = (images.data.pop if images[-1].instance_of? Pagination)
		        self.state.pagination = x
		      end
		      set_state images: images
		    end.fail do |pr|
		      `console.log(#{pr})`
		    end
		  end

		  def render
		    t(:div,{},
          t(:div, {},
            t(Components::Images::SearchBar, {search_for_image: ->(img){perform_search(img)}})
          ),
		      *splat_each(state.images) do |image|
		        t(:div, {key: "#{image}", style: {width: "200px", height: "200px"}},
		          t(:image, {src: image.url, style: {width: "100%", height: "auto"}}),
		          t(:button, {onClick: ->(){destroy(image)}}, "destroy this image"),
		          t(:br, {})
		          #t(:button, {onCLick: ->(){show(image)}})
		        )
		      end,
		      t(:div, {className: "pagination"},
		        *if state.pagination
		          will_paginate
		        end
		      ),
		      t(:br, {}),
		      t(Components::Images::Create, {on_create: ->(image){add_image(image)}})
		    )
		  end

      def perform_search(img)
        ::App.history.replaceState(nil, "#{props.location.pathname}?#{img.attributes}")

        Image.index({},{extra_params: img.attributes}).then do |images|
          if x = (images.data.pop if images[-1].instance_of? Pagination)
            self.state.pagination = x
          end
          set_state images: images
        end
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
		  	::App.history.replaceState(nil, "#{props.location.pathname}?page=#{pa}")

		    Image.index({},{extra_params: {page: pa}}).then do |images|
		      if x = (images.data.pop if images[-1].instance_of? Pagination)
		        self.state.pagination = x
		      end
		      set_state images: images
		    end
		  end

		  def destroy(image)
		    image.destroy.then do |r|
		      state.images.remove(image)
		      set_state images: state.images
		    end
		  end

		  def add_image(image)
		    (state.images << image)
		    set_state images: state.images
		  end

		  
		end
	end
end