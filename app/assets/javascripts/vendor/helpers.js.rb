
module Helpers
	class Cookie
		def self.get()
			c = `document.cookie`
			x = c.include? "l="
		end
	end

	module RRouter

	end

	class ::RW

		def link_to(body, link, options = nil)
	   if block_given?
	    body = yield
	   end
	    t(`Link`, {to: link, query: options}, body)    
	  end

	  attr_accessor :has_spinner

	  require "components/shared/spinner"
	  def spinner
	  	@has_spinner = true
	    t(Shared::Spinner, {ref: "spinner"})
	  end

	  def spinner_instance
	  	ref(:spinner).__opalInstance
	  end

	end

	class ::RequestHandler

		def defaults_on_response
    	(@component.spinner_instance.off if @component.has_spinner) if @component
	  end

	  def defaults_before_request
	    (@component.spinner_instance.on if @component.has_spinner) if @component
	  end

	  def authorize!
	    #LOGIC ON 401 RESPONSE
	  end
	end


end