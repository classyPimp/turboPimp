module Helpers
	class Cookie
		def self.get()
			c = `document.cookie`
			x = c.include? "l="
		end
	end
end