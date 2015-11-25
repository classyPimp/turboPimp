module Components
  module App
    class Forbidden < RW
      expose

      def render
        t(:div, {}, 
          t(:h1, {}, "forbidden 401")
        )
      end
    end
  end
end