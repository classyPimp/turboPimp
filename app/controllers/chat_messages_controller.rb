class ChatMessagesController < ApplicationController

  def create

    perms_for ChatMessage
    auth! @perms

    permitted_attributes = AttributesPermitter::ChatMessages::Create.new(params).get_permitted

    cmpsr = ComposerFor::ChatMessages::Create.new(ChatMessage.new, permitted_attributes, current_user, self)

    cmpsr.when(:ok) do |chat_message|
      render json: chat_message.as_json(@perms.serialize_on_success)
    end

    cmpsr.when(:fail) do |chat_message|
      render json: chat_message.as_json(@perms.serialize_on_error)
    end

    cmpsr.run

  end

  def index
    
    perms_for ChatMessage
    auth! @perms

    @chat_messages = ChatMessage.where(user_id: current_user.id)

    render json: @chat_messages.as_json(@perms.serialize_on_success)

  end

end
