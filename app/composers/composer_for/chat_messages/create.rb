 class ComposerFor::ChatMessages::Create

  include Services::PubSubBus::Publisher

  def initialize(chat_message, permitted_attributes, current_user, controller)
    @chat_message = chat_message
    @permitted_attributes = permitted_attributes
    @current_user = current_user
    @controller = controller  
  end

  def run
    check_if_user_logged_in_or_create
    compose
    clear   
  end

  def check_if_user_logged_in_or_create
    unless @current_user
      cmpsr = ComposerFor::User::Unregistered::CreateVisitor.new(@controller)
      cmpsr.when(:ok) do |user|
        @current_user = user
        check_if_chat_exists_or_create
      end
      cmpsr.run
    else
      check_if_chat_exists_or_create
    end
  end

  def check_if_chat_exists_or_create  
    chat = Chat.find_by(user_id: @current_user.id)
    if chat
      @chat = chat
      prepare_attributes
    else
      @chat = Chat.new
      @chat.user = @current_user
      @chat.save
      prepare_attributes
    end
  end

  def prepare_attributes
    @chat_message.attributes = @permitted_attributes
    @chat_message.user = @current_user
    @chat_message.chat_id = @chat.id
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