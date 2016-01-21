class AppointmentAvailabilitiesController < ApplicationController
  
  def index
    User.arbitrary = {from: params[:from], to: params[:to]} 
    @appointment_availabilities = User.joins(:roles).where("roles.name = 'doctor'").includes(:si_appointment_availabilities1apsindex, :si_profile1id_name).select(:id)
    render json: @appointment_availabilities.as_json(methods: [:si_appointment_availabilities1apsindex, :si_profile1id_name])
    User.arbitrary.delete(:from)
    User.arbitrary.delete(:to)
  end

end
