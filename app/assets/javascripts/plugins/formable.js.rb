module Plugins
	module Formable
=begin 
  EXAMPLE USAGE
  module Users
  class New < RW
    expose

    include Plugins::Formable <= include plugin

    include Plugins::DependsOnCurrentUser
    set_roles_to_fetch :admin

    def prepare_new_user
      ->{
        User.new(profile: {profile: {}}, avatar: {avatar: {}})
      }
    end

    def get_initial_state
      {
        form_model: prepare_new_user.call <= the state that holds your model, form_model is not required name, can be anything
      }
    end

    def render
      t(:div, {},
        t(:div, {className: "form"},
          input(Forms::Input, state.form_model.profile, :name), 
          #=> input method is provided by plugin you must suply name of input comnponet, model that will grab iputs value, attribute, and options
          input(Forms::Input, state.form_model, :email, {type: "text"}),
          input(Forms::Input, state.form_model, :password, {type: "password"}),
          input(Forms::Input, state.form_model, :password_confirmation, {type: "password"}),
          input(Forms::Textarea, state.form_model.profile, :bio),
          input(Forms::Input, state.form_model.avatar, :file, {type: "file", has_file: true, preview_image: true}),
          if state.current_user.has_role? :admin
            input(Forms::Select, state.form_model, :bole, {multiple: true, load_from_server: {url: "/api/test"}})
          else
            spinner(true)
          end,
          t(:br, {}),
          t(:button, {onClick: ->(){handle_inputs}}, "create user")
        )
      )
    end

    def handle_inputs
      collect_inputs #> method provided by plugin, will collect everything, reset_errors (to clear from previous calls), and validate
      p state.form_model.attributes and return
      unless state.form_model.has_errors?
        state.form_model.attributes[:by_admin] = 1
        state.form_model.create({}, {serialize_as_form: true}).then do |model|
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

EXAMPLE INPUT COMPONENT THAT WILL WORK WITH PLUGIN

module Forms
  class Input < RW
    expose
            
    def __component_will_update__
      ref("#{self}").value = "" if props.reset_value == true
      super
    end

    def valid_or_not?
      if props.model.errors[:attr]
        "invalid"
      else
        "valid"
      end
    end

    def optional_props
      opt = {}
      if props.preview_image
        opt[:onChange] = ->(){preview_image}
      end
      opt
    end

    def get_initial_state
      {
        image_to_preview: ""
      } 
    end

    def preview_image
      `
      var file    = #{ref("#{self}").files[0].to_n};
      var reader  = new FileReader();

      reader.onloadend = function () {
        #{set_state image_to_preview: `reader.result`};
      }

      if (file) {
        reader.readAsDataURL(file);
      } else {
        #{set_state image_to_preview: ""};
      }
      `
    end

    def render
      t(:div, {},
        t(:p, {}, props.attr),
        *if props.model.errors[props.attr]
          splat_each(props.model.errors[props.attr]) do |er|
            t(:div, {},
              t(:p, {},
                er
              ),
              t(:br, {})    
            )             
          end
        end,
        t(:input, {className: valid_or_not?, defaultValue: props.model.attributes[props.attr], ref: "#{self}", 
                   type: props.type, key: props.keyed}.merge(optional_props)),
        if props.preview_image
          t(:div, {className: "image_preview"},
            t(:div, {style: {width: "300px", height: "300px"}},
              t(:img, {src: state.image_to_preview, alt: "image_preview", style: {width: "300px", height: "300px"}})
            )
          )
        end,
        children      
      )   
    end

    def collect
      if props.has_file 
        props.model.attributes[props.attr.to_sym] = ref("#{self}").files[0]
      else
        props.model.attributes[props.attr.to_sym] = ref("#{self}").value
      end
    end

    def clear_inputs
      ref("#{self}").value = ""
    end
  end
end

YOU CAN EASILY MAKE ANYTHING WITH THAT OR USE DEFAULTS THAT COME WITH TP

EXAMPLE WITH EXTERNAL JS LIB

module Forms
  class WysiTextarea < RW
    expose

    def __component_will_update__
      ref("#{self}").value = "" if props.reset_value == true
      super
    end

    def valid_or_not?
      if props.model.errors[:attr]
        "invalid"
      else 
        "valid"
      end
    end\

    def render
      @head_content_if_link = t(:p, {}, "choose link")
      @content_if_link = 
          t(:div, {}, 
            t(:p, {}, "link"), 
            t(:input, {type: "text", ref: "insert_link_value"}),
            t(:button, {onClick: ->(){insert_link}}, "insert link")
          )

      @head_if_image = t(:p, {}, "choose image")
      @content_if_image =
          t(:div, {},
            t(Components::Images::Index, {request_on_mount: false, should_expose: {proc: ->(image){insert_image(image)}, button_value: "Copy link"}})
          )

      t(:div, {},
        t(Shared::Modal, {ref: "modal"}),
        t(:p, {}, props.attr),
        *if props.model.errors[props.attr]
          splat_each(props.model.errors[props.attr]) do |er|
            t(:div, {},
              t(:p, {},
                er
              ),
              t(:br, {})    
            )             
          end
        end,
        t(:div, {id: "wysi_toolbar", style: {display: "none"}},
          t(:a, {"data-wysihtml5-command" => "bold"}, "BOLD"),
          t(:a, {"data-wysihtml5-action" => "change_view", "unselectable"=>"on"},
            "switch to html"
          ),
          t(:button, {onClick: ->(){open_modal_for_link}}, "insert link"),
          t(:button, {onClick: ->(){open_modal_for_image}}, "insert image")
        ),
        t(:textarea, {className: "form-control", rows: "5", id: "wysi", defaultValue: props.model.attributes[props.attr]})
      )
    end

    def component_will_unmount
      @wysi_editor.destroy
    end

    def open_modal_for_link
      ref(:modal).__opalInstance.open(@head_content_if_link, @content_if_link)
    end

    def open_modal_for_image
      ref(:modal).__opalInstance.open(@head_if_image, @content_if_image)
    end

    def insert_link
      link = ref("insert_link_value").value
      @wysi_editor.composer.commands.exec("createLink", { href: link})
      ref(:modal).__opalInstance.close
    end

    def insert_image(image)
      @wysi_editor.composer.commands.exec("insertImage", { src: image.url, alt: image.alt });
    end

    def component_did_mount
      @wysi_editor = Native(%x{
        new wysihtml5.Editor("wysi", { 
          toolbar:      "wysi_toolbar",
          parserRules:  wysihtml5ParserRules
        })
      })
    end

    def collect
      props.model.attributes[props.attr.to_sym] = @wysi_editor.getValue
    end


  end
end

=end
 
		#needs state form_model
		#your base should have state.form_model, the Model instance
		#that will contain the validation rules and attr it has
		#and which needs some inputs
		 
		def initialize
			@inputs_counter = -1
			#to understand what it does refer to #input method
			super
		end

		def __component_will_update__
			@inputs_counter = -1
			#to understand what it does refer to #input method
			#here it resets for it not to increment infinitely
			#also this can help in keying inputs probably idk
			super
		end

		def input(elem, model, attr, options = {}, *_children)
			#this method calls the input element that you define for single attr handling
			#model : Model => the model which attrs will take from inputs
			#attr => attribute on model wich will recive value of the input
			#elem => React element which will be used as input handler for attr
			#  			 this element will be rendered
			@inputs_counter += 1
			#the @inputs_counter servers the purpose of giving uniq ref name to the input elem
			#for further accessing it 
			options[:model] = model
			options[:attr] = attr
			options[:ref] = "_input_#{@inputs_counter}"
			#the given ref will go not to the input dom element but the RW element
			#that has to implement collect method (which gets the concrete input)
			#the ref is needed to get taht RW class object (as ref(_input_1).__opalInstance.collect)
	    options[:keyed] = @inputs_counter
	    #probably needs reworking on this can't remember why I did this
			t(elem, options, *_children)
			#basically the result
			#children are children, the life purpose of each element)

			#options will 
		end
		
		def collect_inputs(options = {})
			#so you've called inputs in your render
			#input called the input handling RW class
			#that class was given a ref
			#now with this method you collect all the values from all the inputs
			#at once. The input class should implement #collect method for getting the actual 
			#values from user interactions
			Hash.new(refs.to_n).each do |k,v|
	      if k.include? "_input"
	      #in #input the ref of "_input#{@input_counter}"
	      #so any ref starting _input is input that's how you roll now)
	        v.__opalInstance.collect
	        #as it was mentioned RW class responsible for single attr input handling
	        #should implement #collect method which will get the actual value from user interaction
	      end
	    end
	    #state.form_model.reset_errors 
	    #your input handlers may rely on errors for showing them to user
	    #so it basically resets all errors
	    #TODO: ammend #reset_errors on model if from_model is Asssociation of Model
      #CHANGED: above is not actual reset_errors are called in Model#validate before validation begins
      #and at the end attr[:errors] are cleared as well
      options[:validate_only] ||= []
	    state.form_model.validate(only: options[:validate_only])
	    #Model implements #validate method which does TADA validation!
	    state.form_model
	    #returns the model with inputs
	    #there you do what you want
	    #e.g. collect_inputs.has_errors ? form_model.save : set_state form_model: state.form_model 
	    #=> to either to pass to server, or to show errors 
		end

		def clear_inputs
			Hash.new(refs.to_n).each do |k,v|
				if k.include? "_input"
					v.__opalInstance.clear_inputs if v.__opalInstance.respond_to? :clear_inputs
				end
			end
		end

	end
end
