class AppointmentScheduler::ChatMessagesController < ApplicationController

  def index
    perms_for ChatMessage
    auth! @perms.appointment_scheduler_index

    @messages = ChatMessage.all
    @users = User.where('id in (?)', @messages.map(&:user_id).uniq).select(:id).includes(:si_profile1name_phone_number)
    render json: {users: @users.as_json(only: [:id], include: [si_profile1name_phone_number: {root: true}]), messages: @messages.as_json}

  end

  def poll_index
    perms_for ChatMessage
    auth! @perms.appointment_scheduler_poll_index

    @messages = ChatMessage.where('id > ?', params[:last_id])
    @users = User.where('id in (?)', @messages.map(&:user_id).uniq).select(:id).includes(:si_profile1name_phone_number)
    render json: {users: @users.as_json(only: [:id], include: [si_profile1name_phone_number: {root: true}]), messages: @messages.as_json}
  end

  def create
    
    perms_for ChatMessage
    auth! @perms.appointment_scheduler_create

    permitted_attributes = AttributesPermitter::ChatMessages::Create.new(params).get_permitted
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
