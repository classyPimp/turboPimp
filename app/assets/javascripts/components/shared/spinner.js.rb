module Shared
	class Spinner	< RW
		expose_as_native_component

		def initial_state
			{
				on: false
			}
		end

		def render
			t(:div, {className: "cssload-container", style: {display: state.on}}, 
				t(:div, {className: "cssload-speeding-wheel"})
			)
		end

		def on
			set_state on: "inline"
		end

		def off
			set_state on: "none"
		end
	end
end