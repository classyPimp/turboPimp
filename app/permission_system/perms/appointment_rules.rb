module Perms
  class AppointmentRules < Perms::Base


    def doctor_create
      if @current_user && @current_user.has_role?(:doctor)

        @permitted_attributes = params.require(:appointment).
          permit(:start_date, :end_date, :patient_id, appointment_detail_attributes: [:note])

        @permitted_attributes[:doctor_id] = @current_user.id
        @permitted_attributes[:scheduled] = true
        @permitted_attributes[:user_id] = @current_user.id
        @serialize_on_success = {include: [patient: {root: true, include: [profile: {root: true}]}]}
        @serialize_on_error = {methods: [:errors]}
        
      end
    end

    def create
      if @current_user 

        params.require(:appointment).require(:appointment_proposal_infos_attributes)
        @permitted_attributes = params.require(:appointment).
          permit(appointment_proposal_infos_attributes: [:any_time_for_date, :doctor_id, :date_from, :date_to])

        @permitted_attributes[:patient_id] = @current_user.id
        @permitted_attributes[:proposal] = true
        @serialize_on_success = {only: [:id]}
        @serialize_on_error = {methods: [:errors]}
        
      else
        params.require(:appointment).require(:appointment_proposal_infos_attributes)
        @permitted_attributes = params.require(:appointment).
          permit(appointment_proposal_infos_attributes: [:any_time_for_date, :doctor_id, :date_from, :date_to])
        @permitted_attributes[:proposal] = true
        @arbitrary[:unregistered_user_permitted_attributes] = params.require(:user).permit(profile_attributes: [:phone_number, :email, ])
      end

    end

    def edit
      if @current_user && @current_user.has_role?(:doctor)
        true
      end
    end

    def index
      if @current_user && @current_user.has_role?(:doctor)
        true
      end
    end

    def show
      if @current_user && @current_user.has_role?(:doctor)
        true
      end
    end

    def doctor_update
      if @current_user && @current_user.has_role?(:doctor)
        @permitted_attributes = params.require(:appointment).
          permit(:start_date, :end_date, :patient_id, appointment_detail_attributes: [:note, :id, :appointment_id])
        @serialize_on_error = {methods: [:errors]}
      end
    end

    def destroy
      if @current_user && @current_user.has_role?(:doctor)
        true
      end
    end
      
  end
end