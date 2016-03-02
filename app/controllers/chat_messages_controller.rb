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
    if current_user
      @chat = Chat.where(user_id: current_user.id)
    else
      @chat = []
    end

    render json: @chat[0].as_json(@perms.serialize_on_success)

  end

  def poll_index
    perms_for ChatMessage
    auth! @perms

    @chat_messages = ChatMessage.where('id > ? and user_id = ?', params[:last_id], current_user.id)
    @user_ids_to_query = @chat_messages.map(&:user_id)
    @user_ids_to_query = @user_ids_to_query.uniq - [current_user.id]
    @users = User.where('id in (?)', @user_ids_to_query).select(:id).includes(:si_profile1id_name)

    render json: {users: @users.as_json(include: [si_profile1id_name: {root: true}]), chat_messages: @chat_messages.as_json}

  end

end
