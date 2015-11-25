module Components
	module Images
		class Index < RW

			expose
      include Plugins::Paginatable

			def initial_state
		    {
		      images: ModelCollection.new,
          query: ""
		    }
		  end

		  def component_did_mount
		    Image.index.then do |images|
		      extract_pagination(images)
		      set_state images: images
          p "set_state"
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
              t(:p, {}, "alt: #{image.alt}, description: #{image.description}"),
		          t(:image, {src: image.url, style: {width: "100%", height: "auto"}}),
		          t(:button, {onClick: ->(){destroy(image)}}, "destroy this image"),
		          t(:br, {})
		          #t(:button, {onCLick: ->(){show(image)}})
		        )
		      end,
		      will_paginate,
		      t(:br, {}),
		      t(Components::Images::Create, {on_create: ->(image){add_image(image)}})
		    )
		  end

      def perform_search(img)
        ::App.history.replaceState(nil, "#{props.location.pathname}?#{`$.param({search_query: #{img.attributes[:search_query].to_n}})`}")
        Image.index({},{extra_params: img.attributes}).then do |images|
          extract_pagination(images)
          set_state images: images
        end
      end

		  def pagination_switch_page(page)
		  	::App.history.replaceState(nil, "#{props.location.pathname}?page=#{page}")
		    Image.index({},{extra_params: {page: page}}).then do |images|
		      extract_pagination(images)
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