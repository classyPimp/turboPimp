class AppointmentScheduler::ChatMessagesController < ApplicationController

  def index
    
    perms_for ChatMessage
    
    auth! @perms.appointment_scheduler_index

    @chat = Chat.all.includes(si_user1id_email_registered: [:si_profile1id_name])
    
    render json: @chat.as_json(@perms.serialize_on_success)

  end

  def poll_index

    perms_for ChatMessage
    auth! @perms.appointment_scheduler_poll_index

    Chat.arbitrary[:last_id_for_polling] = params[:last_id]
    
    @chats = Chat.joins(:chat_messages).where('chat_messages.id > ?', params[:last_id])#.includes([{si_user1id_email_registered: [:si_profile1id_name]}, :si_chat_messages1after_id])

    render json: @chats.as_json(@perms.serialize_on_success)

    Chat.arbitrary.delete(:last_id_for_polling)
  
  end

  def create
    
    perms_for ChatMessage
    auth! @perms.appointment_scheduler_create
  
    permitted_attributes = AttributesPermitter::AppointmentScheduler::ChatMessages::Create.new(params).get_permitted
    cmpsr = ComposerFor::AppointmentScheduler::ChatMessages::Create.new(ChatMessage.new, permitted_attributes, current_user)

    cmpsr.when(:ok) do |chat_message|
      render json: chat_message.as_json(@perms.serialize_on_success)
    end

    cmpsr.when(:fail) do |chat_message|
      render json: chat_message.as_json(@perms.serialize_on_error)
    end

    cmpsr.run

  end

 

end
