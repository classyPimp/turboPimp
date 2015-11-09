class Filer < Model

	attributes :file, :name, :id, :users

	route "upload", post: "test"

	def responses_on_upload(r)
		if r.response.ok?
        r.promise.resolve(r.response)
    else
      r.promise.reject(r.response)
    end
	end

	def validate_file
		string_rep_deepness = "#{passed_deepness}#{self.class.name.downcase}[file]"
		has_file << "file"
	end

end


module Forms
	class WysiTextarea < RW
		expose

		def initial_state
			{
				foo: "bar",
				file: Filer.new
			}
		end

		def render
			t(:div, {},
				t(:p, {}, "#{state.foo}"),
				t(:p, {}, "upload file"),
				t(:input, {type: "file", ref: "file"}),
				t(:br, {}),
				t(:button, {onClick: ->(){handle_upload}}, "collectfile"),
				t(:br, {}),
				t(:div, {id: "wysi_toolbar", style: {display: "none"}},
					t(:a, {"data-wysihtml5-command" => "bold"}, "BOLD"),
					t(:a, {"data-wysihtml5-action" => "change_view", "unselectable"=>"on"},
						"switch to html"
					)
				),
				t(:textarea, {className: "form-control", rows: "5", id: "wysi"}),
				t(:br, {}),
				t(:button, {onClick: ->(){p @wysi_editor.getValue}}, "click me for value")
			)
		end


		
		def handle_upload

			form_data = Native(`new FormData()`)

			state.file.name = "JOHNATAN!"
			state.file.id = "WUUURHA"
			state.file.file = ref(:file).files[0]
			p state.file.pure_attributes
			#form_data = Model.iterate_for_form(state.file.pure_attributes, form_data)
			#state.file.upload({}, {data: form_data, processData: false, contentType: false})
			
		end

		def component_will_unmount
			@wysi_editor.destroy
		end

		def component_did_mount
			@wysi_editor = Native(%x{
				new wysihtml5.Editor("wysi", { 
				  toolbar:      "wysi_toolbar",
				  parserRules:  wysihtml5ParserRules
				})
			})
		end
	end
end

