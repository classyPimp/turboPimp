
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
	  require "components/shared/spinner"
	  def spinner
	    t(Shared::Spinner, {ref: "spinner"})
	  end

	end
end