class Appointments::AvailabilitiesController < ApplicationController

  def index

    User.arbitrary[:from] = params[:from]
    User.arbitrary[:to] = params[:to] 

    @users_with_appointments = User.joins(:appointments_as_doctor).where("appointments.start_date >= ? AND appointments.end_date < ?", User.arbitrary[:from], User.arbitrary[:to]).select(:id).distinct#.includes(:si_appointments1as_patient_all, :profile_id_name, :avatar)
    
    render json: @users_with_appointments.as_json(
      {
        include: 
        [
          {
            si_appointments1as_patient_all:
            {
              root: true
            }
          },
          {
            si_profile1id_name:
            {
              root: true
            }
          },
          {
            avatar:
            {
              root: true,
              methods:
              [
                :url
              ]
            }
          }
        ]
      }
    )
        

  end

end
