class Dummy < RW

	def initial_state
		@foo = [1,2,3]
		{
			menu: Menu.new([["foo", "bar"], ["dooz", [["asd", "bsd"]]], ["baz", [["a","b"], ["c", [["foo","bar"], ["baz", "laz"]]]]]])
		}
	end

	def render
		t(:div, {}, 
			t(:p, {}, "This is test route"),
			t(:p, {onClick: ->(){add_menu(state.menu)}}, "add item"),
		  *recurs_menu(state.menu.data)
		)
	end

	def recurs_menu(ary, item=nil)
		splat_each_with_index(ary, item) do |v, i, item|
			t(:div, {}, 
				if v.data[1].is_a? Array
					t(:div, {}, 
					 	t(:p, {}, "#{v.data[0]}: "),
						 	t(:div, {style: {"paddingLeft" => "1em"}},
						 		t(:p, {onClick: ->(){add_menu(v)}}, "add here"),
						 		*recurs_menu(v.data[1])
					  	)
					  )
				else
					t(:div, {},
					  t(:div, {}, "#{v.data[0]} : #{v.data[1]}"),
					  t(:p, {onClick: ->(){add_menu(v)}}, "add here")
					)
				end
			)
		end
	end

	def add_menu(menu)
		if menu.is_a? MenuItem
			if menu.data[1].is_a? String
				menu.data[1] = []
			end
			menu.data[1] << MenuItem.new(["new", "new href"]) 
		else
			menu.data << MenuItem.new(["foo", "bar"])
		end
		set_state menu: state.menu
	end
end

class Menu

  attr_accessor :data

  def initialize(ary )
    @data = []
    ary.each do |v|
      @data << MenuItem.new(v)
    end
  end

  def serialize_data
  	@data.map do |v|
  		if v.is_a? menuItem
  			recurs_part(v)
  		else
  			v
  		end
  	end
  end

  def recurs_part(data)
  	v.data.map do |v|
  		if v[1].is_a? Array
  			recurs_part(v[1])
  		else
  			v.data
  		end
  	end
  end

end

class MenuItem
  
  attr_accessor :data

  def initialize(ary)
    @data = []
    if ary[1].is_a? Array
      @data[0] = ary[0]
      @data[1] = []
      ary[1].each do |v|
        @data[1] << MenuItem.new(v)
      end
    else
      @data[0] = ary[0]
      @data[1] = ary[1]  
    end 
  end

end


class Page < Model
	
	attributes :name, :email

	def init
		
	end

	def validation_rules
		{
			name: ->{validate_name},
			email: ->{validate_email}
		}
	end

	def reset_errors
		@errors = {}
	end

	def validate_name
	  if name.length < 8
	  	(@errors[:name] ||= []) << "can't be less than 8 chars long"
	  end
	end

	def validate_email
		if email.length < 6
			(@errors[:email] ||= []) << "invalid email"
 		end
	end

	def validate
		@attributes.each do |k, v|
			if v.is_a? Model
				v.validate
				if v.has_errors
					@errors[:thereareerrors] = true				
				end
			else
				self.send("validate_#{k}") if self.respond_to? "validate_#{k}"
			end
		end
	end

end

class Input < RW

	expose_as_native_component

	def component_will_unmount
		p "unmounted #{self}"
	end

	def component_will_update
		p "will upddate #{self}"
	end

	def valid_or_not?
		if props.model.has_errors?
			"invalid"
		else
			"valid"
		end
	end

	def render
		t(:div, {},
			t(:p, {}, "#{props.adress}"),
			*if props.model.has_errors?
				p props.model.errors
				splat_each(props.model.errors[props.adress]) do |er|
					t(:div, {},
						t(:p, {},
							er
						),
						t(:br, {})		
					)							
				end
			end,
			t(:input, {className: valid_or_not?, defaultValue: props.model.attributes[props.adress], ref: "#{self}", 
			type: props.type}),
			children			
		)		
	end

	def collect
		props.model.attributes[props.adress] = ref("#{self}").value
	end
	
end

class Foo < RW
	expose_as_native_component
	attr_accessor :inputs
	def init
		@inputs_counter = 0
	end

	def method_name
		
	end

	def initial_state	
		{
			model: Model.parse(page: {email: "asd", password: "qweasd"})
		}
	end

	def render
		@inputs = []
		t(:div, {},
			input(state.model, :email, :text),
			input(state.model, :password, :text),
			t(:button, {onClick: ->{handle}}, "collect")
		)
	end

	def handle
		p Hash.new(refs)
	end

	def input(model, adress, type, options = {})
		@inputs_counter += 1
		options[:model] = model
		options[:adress] = adress
		options[:type] = type
		options[:ref] = "_input_#{@inputs_counter}"
		t(Input, options, (yield if block_given?))
	end
end

