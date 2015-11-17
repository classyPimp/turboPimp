module Components
	module Images
		class Create < RW
			expose

			include Plugins::Formable

			def initial_state	
				{
					form_model: false
				}
			end

		  def init_image_creation
		    self.set_state form_model: Image.new
		  end

			def render
			  t(:div, {},
		      if state.form_model
		        t(:div, {}, 
		          input(Forms::Input, state.form_model, :file, {type: "file", has_file: true}),
		          t(:button, {onClick: ->(){handle_inputs}}, "create image")
		        )
		      else
		        t(:button, {onClick: ->(){init_image_creation}}, "I WANT SOME IMAGES TO CREATE!")
		      end
		    )
			end

		  def handle_inputs
		    collect_inputs
		    unless state.form_model.has_errors?
		      state.form_model.create.then do |model|
		        if model.has_errors?
		          set_state form_model: model
		        else
		          set_state form_model: false
		          props.on_create(model)
		        end
		      end
		    else
		      set_state form_model: state.form_model
		    end
		  end


		end
	end
end