class AttributesPermitter::ChatMessages::Create

  def initialize(params)
    @params = params.require(:chat_message)
  end

  def get_permitted
    @permitted_attributes = @params.
      permit(:text)
    @permitted_attributes
  end

end