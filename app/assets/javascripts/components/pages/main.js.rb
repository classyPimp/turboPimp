module Components
  module Pages
    class Main < RW
      expose

      def render
        t(:div, {className: "pages"},
          children
        )
      end
    
    end
  end
end
