module Components
  module Admin
    class Main < RW
      expose

      def render
        t(:div, {},
          children
        )
      end

    end
  end
end
