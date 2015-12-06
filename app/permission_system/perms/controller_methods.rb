module Perms
  module ControllerMethods

    def auth!(return_value)
      if return_value.is_a? Perms::Base
        return_value = return_value.public_send(self.action_name)
      end
      raise Perms::Exception unless return_value 
    end

    def perms_for(model, options = {})
      Perms::Factory.build(model, self, options)
    end
  end
end