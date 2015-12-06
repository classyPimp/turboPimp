module Perms
  class Base

    attr_accessor :permitted_attributes

    def initialize(model, controller, options)
      @options = options
      @current_user = controller.current_user
      @controller = controller
      @model = model
      @permitted_attributes = false
    end

  end
end