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
          elsif props.location.query.status_code == "400"
            t(:h1, {}, "Bad request 400")
          else
            t(:h1, {}, "page not found or error occured 404")
          end
        )
      end
    end

  end
end