=begin
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
=end
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
=begin
class Page < Model

  attributes :id, :body, :text, :user

  route "create", post: "pages"
  route "Index", get: "pages"
  route "destroy", {delete: "pages/:id"}, {defaults: [:id]}
  route "update", {put: "pages/:id"}, {defaults: [:id]}

  def validate_body(options = {})
    if body.length < 4
      add_error(:body, "too short!")
    end
  end
end


class PageIndex < RW
  expose

  def initial_state
    {
      pages: ModelAssociation.new
    }
  end

  def component_did_mount
    Page.index.then do |pages|
      set_state pages: pages
    end
  end

  def render
    t(:div,{},
      *splat_each(state.pages) do |page|
        t(:div, {key: "#{page}"},
          t(:p, {}, "body: #{page.body}"),
          t(:p, {}, "text: #{page.text}"),
          t(:button, {onClick: ->(){init_page_edit(page)}}, "edit this page"),
          t(:button, {onClick: ->(){destroy(page)}}, "destroy this page")
          #t(:button, {onCLick: ->(){show(page)}})
        )
      end,
      t(PageCreate, {on_create: ->(page){add_page(page)}}),
      t(PageEdit, {on_edit_done: ->(page){update_page(page)}, ref: "page_edit_form"})
    )
  end

  def destroy(page)
    page.destroy.then do |r|
      state.pages.remove(page)
      set_state pages: state.pages
    end
  end

  def init_page_edit(page)
    ref(:page_edit_form).__opalInstance.init_page_edit(page)
  end

  def add_page(page)
    (state.pages << page)
    set_state pages: state.pages
  end

  def update_page(page)
    set_state pages: state.pages
  end
end

class PageCreate < RW
	
  expose

  include Plugins::Formable

	def initial_state	
		{
			form_model: false
		}
	end

  def init_page_creation
    self.set_state form_model: Page.new
  end

	def render
	  t(:div, {},
      if state.form_model
        t(:div, {}, 
          input(Forms::Input, state.form_model, :text, {type: "text"}),
          input(Forms::Input, state.form_model, :body, {type: "text"}),
          t(:button, {onClick: ->(){handle_inputs}}, "create page")
        )
      else
        t(:button, {onClick: ->(){init_page_creation}}, "I WANT SOME PAGES TO CREATE!")
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

class PageEdit < RW
  expose

  include Plugins::Formable

  def initial_state 
    {
      form_model: false
    }
  end

  def init_page_edit(page)
    self.set_state form_model: page
  end

  def render
    t(:div, {},
      if state.form_model
        t(:div, {}, 
          input(Forms::Input, state.form_model, :text, {type: "text"}),
          input(Forms::Input, state.form_model, :body, {type: "text"}),
          t(:button, {onClick: ->(){handle_inputs}}, "commit edit")
        )
      end
    )
  end

  def handle_inputs
    collect_inputs
    unless state.form_model.has_errors?
      state.form_model.update.then do |model|
        if model.has_errors?
          set_state form_model: model
        else
          p "WHATTAP"
          set_state form_model: false
          props.on_edit_done(model)
        end
      end
    else
      set_state form_model: state.form_model
    end.fail do |resp|
      raise "PROMISE FAILED!"
    end
  end
end

=end

