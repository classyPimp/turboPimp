module Shared
  module Flash

    class Message

      attr_accessor :type, :dismissible, :body

      def initialize(body, type = "sucess",d_ble = true)
        @data = []
        @type = type
        @body = body
        @dismissible = d_ble 
      end

    end

  end
end