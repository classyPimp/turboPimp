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
          query: "",
          non_url_pagination: true,
          pagination_per_page: 1,
          search_query: {}
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
		    t(:div,{className: 'images_index'},
          t(Components::Images::SearchBar, {search_for_image: ->(img){perform_search(img)}}),
          t(:div, {className: 'search_results'}, 
  		      *splat_each(state.images) do |image|
  		        t(:div, {key: "#{image}", className: 'image_holder' },
                t(:p, {}, "alt: #{image.alt}, description: #{image.description}"),
  		          t(:image, {src: image.url, className: 'image' }),
                t(:div, {className: 'btn_group'}, 
                  t(:button, {className: 'btn btn-xs', onClick: ->(){destroy(image)}}, "destroy this image"),
                  if props.should_expose
                    t(:button, {className: 'btn btn-xs', onClick: ->(){props.should_expose[:proc].call(image)}}, props.should_expose[:button_value])
                  end
                )
  		        )
  		      end
          ),
		      will_paginate,
          spinner,
		      t(:br, {}),
		      t(Components::Images::Create, {on_create: ->(image){on_create(image)}})
		    )
		  end


      def make_query(_extra_params)
        Image.index({extra_params: _extra_params, component: self}).then do |images|
          begin
            extract_pagination(images)
            set_state images: images, search_query: _extra_params, pagination_per_page: _extra_params[:per_page]
          rescue Exception => e
            p e
          end
        end
      end

      def perform_search(img)
        #Components::App::Router.history.pushState(nil, "#{props.location.pathname}?#{`$.param({search_query: #{img.attributes[:search_query].to_n}})`}") unless props.should_expose
        # Image.index({extra_params: (img.attributes).merge(per_page: state.pagination_per_page)}).then do |images|
        #   begin
        #     extract_pagination(images)
        #     set_state images: images, search_query: img.attributes
        #   rescue Exception => e
        #     p e
        #   end
        # end
        query = state.search_query
        query[:per_page] = state.pagination_per_page
        query[:page] = 1
        query.merge!(img.attributes)
        make_query(query)
      end

		  def pagination_switch_page(page, event)
        `#{event}.preventDefault()`
		  	#Components::App::Router.history.pushState(nil, "#{props.location.pathname}?page=#{page}")
        query = state.search_query
        query[:page] = page
        make_query(query)
		  end

      def per_page_select(per_page_num)
        query = state.search_query
        query[:per_page] = per_page_num
        query[:page] = 1
        make_query(query)
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