module Components
  module App

    class NotFound < RW
      expose

      def render
        t(:div, {},
          if props.location.query.status_code == "404"
            t(:h1, {}, "Page not found 404")
          elsif props.location.query.status_code == "500"
            t(:h1, {}, "Internal server error 500")
          end
        )
      end
    end

  end
end