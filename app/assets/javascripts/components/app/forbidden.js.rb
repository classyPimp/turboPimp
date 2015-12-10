module Components
  module App
    class Forbidden < RW
      expose

      def render
        t(:div, {}, 
          t(:h1, {}, "forbidden 403")
        )
      end
    end
  end
end