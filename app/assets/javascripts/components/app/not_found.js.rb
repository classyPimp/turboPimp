module Components
  module App

    class NotFound < RW
      expose

      def render
        t(:div, {},
          t(:h1, {}, "Page not found 401")
        )
      end
    end

  end
end