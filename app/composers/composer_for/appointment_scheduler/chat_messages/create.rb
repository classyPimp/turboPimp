class ComposerFor::AppointmentScheduler::ChatMessages::Create

  include Services::PubSubBus::Publisher

  def initialize(chat_message, permitted_attributes, current_user)
    @chat_message = chat_message
    @permitted_attributes = permitted_attributes
    @current_user = current_user
  end

  def run
    prepare_attributes
    compose
    clear   
  end

  def prepare_attributes
    @chat_message.attributes = @permitted_attributes
    @chat_message.user = current_user.id
    @chat_message.read = true
  end

  def compose

    if @chat_message.save
      publish(:ok, @chat_message)
    else
      publish(:fail, @chat_message)
    end   
    
  end

  def clear
    unsubscribe_all
  end

end