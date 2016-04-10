class AppointmentScheduler::ChatsController < ApplicationController

  def destroy
    
    @chat = Chat.find(params[:id])

    perms_for @chat
    auth! @perms.appointment_scheduler_destroy

    @chat.destroy

    render json: @chat.as_json(only: [:id])

  end

end
 