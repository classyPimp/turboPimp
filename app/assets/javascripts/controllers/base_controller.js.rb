class BaseController
  
  attr_accessor :component
  
  def initialize(obj)
    @component = obj
  end

  def c
  	@component
  end
end
