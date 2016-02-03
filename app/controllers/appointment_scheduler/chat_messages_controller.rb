class AppointmentScheduler::ChatMessagesController < ApplicationController

  def index
    perms_for ChatMessage
    auth! @perms.appointment_scheduler_index

    @users_with_messages = User.joins(:chat_messages).select(:id, :registered).distinct.includes(:chat_messages, :si_profile1name_phone_number)
   # @users_with_messages.includes(:chat_messages, :si_profile1name_phone_number)
    render json: @users_with_messages.as_json(@perms.serialize_on_success)

  end

end
