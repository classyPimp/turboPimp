module  Users

  class Main < RW
      
    def render
      t(:div, {}, 
        children
      )
    end

  end

end