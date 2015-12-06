module Perms
  class Exception < StandardError

    def initialize(msg = "PERMS UNATHORIZED")
      super(msg)
    end

  end
end