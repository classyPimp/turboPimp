module Components
	module Images
		class Index < RW

			expose
      include Plugins::Paginatable

      #PROPS:
      # => request_on_mount: Boolean
      #if false won't request images from server
      #used for image linking with wysi
      #if prop is not provided accounted as true
      # => expose_image: Hash with values {proc: ->(){PROC YOU WANT TO CALL ON PARENT}, button_value: "THE VALUE WHICH WILL BE PASSED TO BUTTON ELEM"}
      #if provided under each rendered image button will be added with value of props.expose_image
      #which will have call the props.expose_image[:proc].call(image) on click

			def get_initial_state
		    {
		      images: ModelCollection.new,
          query: ""
		    }
		  end

		  def component_did_mount
        unless props.request_on_mount == false
  		    Image.index.then do |images|
  		      extract_pagination(images)
  		      set_state images: images
  		    end.fail do |pr|
  		      `console.log(#{pr})`
  		    end
        end
		  end

		  def render
		    t(:div,{},
          t(:div, {},
            t(Components::Images::SearchBar, {search_for_image: ->(img){perform_search(img)}})
          ),
		      *splat_each(state.images) do |image|
		        t(:div, {key: "#{image}", style: {width: "200px", height: "200px"}.to_n },
              t(:p, {}, "alt: #{image.alt}, description: #{image.description}"),
		          t(:image, {src: image.url, style: {width: "100%", height: "auto"}.to_n }),
		          t(:button, {onClick: ->(){destroy(image)}}, "destroy this image"),
              if props.should_expose
                t(:button, {onClick: ->(){props.should_expose[:proc].call(image)}}, props.should_expose[:button_value])
              end,
		          t(:br, {})
		          #t(:button, {onCLick: ->(){}})
		        )
		      end,
		      will_paginate,
		      t(:br, {}),
		      t(Components::Images::Create, {on_create: ->(image){on_create(image)}})
		    )
		  end

      def perform_search(img)
        Components::App::Router.history.pushState(nil, "#{props.location.pathname}?#{`$.param({search_query: #{img.attributes[:search_query].to_n}})`}") unless props.should_expose
        Image.index({},{extra_params: img.attributes}).then do |images|
          extract_pagination(images)
          set_state images: images
        end
      end

		  def pagination_switch_page(page)
		  	#Components::App::Router.history.pushState(nil, "#{props.location.pathname}?page=#{page}")
		    Image.index({},{extra_params: {page: page}}).then do |images|
		      extract_pagination(images)
		      set_state images: images
		    end
		  end

      def on_create(image)
        state.images << image
        self.set_state images: state.images
      end

		  def destroy(image)
		    image.destroy.then do |r|
		      state.images.remove(image)
		      set_state images: state.images
		    end
		  end
		  
		end
	end
end