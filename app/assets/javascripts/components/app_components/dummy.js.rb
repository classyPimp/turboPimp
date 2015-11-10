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

=begin
class Page < Model
	
	attributes :name, :email, :password, :pages

	def validate_name(options = {})
    p "validating name"
	  if name.length < 8
	  	(@errors[:name] ||= []) << "can't be less than 8 chars long"
	  end
	end

	def validate_email(options = {})
		if email.length < 6
			(@errors[:email] ||= []) << "invalid email"
 		end
	end

  def validate_password(options = {})
    if password.length < 5
      add_error(:password, "too short")
    end
  end

end
=end
class Foo < RW
	
  expose

  include Plugins::Formable

	def initial_state	
		{
			form_model: Model.parse(page: {email: "asd", password: "qwe", password_confirmation: "asd",
                         pages: []})
		}
	end

	def render
=begin
		t(:div, {},
			input(Forms::Input, state.form_model, :email, {}),
			input(Forms::Input, state.form_model, :password, {}),
      input(Forms::Input, state.form_model, :password_confirmation, {reset_value: true}),
      *splat_each_with_index(state.form_model.pages) do |model, index|
        t(:div, {key: "#{model}"},
          input(Forms::Input, model, :email, {}),
          input(Forms::Input, model, :password, {}),
          t(:button, {onClick: ->{remove(state.form_model.pages, index)}}, "remove")
        ) unless model == nil
      end,
      t(:button, {onClick: ->{add(state.form_model.pages, Page.new)}}, "add"),
      
			t(:button, {onClick: ->{handle_inputs}}, "collect")
		)
=end
	t(:p, {}, "The foo!")
	end

  def handle_inputs
    set_state form_model: collect_inputs
  end

  def remove(_model, i)
    _model.delete_at i
    set_state form_model: state.form_model
  end

  def add(_model, val)
    _model.push val
    set_state form_model: state.form_model
  end

end


class Page < Model

	attributes :id, :body, :text, :user

	route "create", post: "pages"

end


Document.ready? do
	page = Page.new
	page.text = "12345"
	page.body = "The sexy body!"
	page.create.then do |r|
		page.validate
		p "calling has_errors from response"
		page.has_errors?
		p "printin attributes"
		p page.attributes
		p "printing errors"
		p page.errors
		
	end.fail do |r|
		p r
	end
end

