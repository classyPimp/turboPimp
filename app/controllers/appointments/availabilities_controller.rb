class Appointments::AvailabilitiesController < ApplicationController

  def index

    from = Date.parse(params[:from])
    to = Date.parse(params[:to])

    @appointments = User.joins(:roles, :appointments_as_doctor).where('roles.name = ?', 'doctor').where('appointments.start_date >= ? AND appointments.end_date <= ?', from, to).select(:id)

    render json: @appointments.as_json(
      {
        include: 
        [
          {
            si_profile1id_name:
            {
              root: true
            }
          },
          {
            appointments_as_doctor:
            {
              root: true
            }
          }
        ]
      }
    )
        

  end

end
