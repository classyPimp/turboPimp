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
        
        self.arbitrary[:registered_user] = true

        @serialize_on_success = {only: [:id]}
        @serialize_on_error = {only: [], methods: [:errors], include: [{appointment_detail: { root: true ,only: [], methods: [:errors]}}]}  

        return true

      else
        
        self.arbitrary[:registered_user] = false

        @serialize_on_success = {only: [:id]}
        @serialize_on_error = {only: [], methods: [:errors], include: [{appointment_detail: { root: true, only: [], methods: [:errors]}}]} 
        
        return true
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

    def appointment_scheduler_proposal_index
      if @current_user && @current_user.has_role?(:appointment_scheduler)
        @serialize_on_success = 
        {
          include: 
          [ 
            {
              si_appointment_proposal_infos1all: 
              {
                root: true, include: 
                [
                  {
                    si_doctor1id: 
                    {
                      root: true, only: [:id], include: 
                      [
                        si_profile1id_name: { root: true, only: [:id, :user_id, :name] }
                      ]
                    }
                  }
                ]
              }
            },
            {
              patient:
              {
                root: true, include: 
                [
                  si_profile1name_phone_number: { root: true, only: [:id, :user_id, :name, :phone_number] }
                ]
              }
            },
            {
              si_appointment_detail1extra_details:
              {
                root: true
              }
            }
          ]
        }
        return true
      end
    end

    def appointment_scheduler_index
      if @current_user && @current_user.has_role?(:appointment_scheduler)
        @serialize_on_success =
        {
          include:
          [
            {
              si_appointments1as_doctor_all: 
              {
                root: true
              }
            },
            {
              si_profile1id_name:
              {
                root: true
              }
            }
          ]
        }
        return true
      end
    end

    def appointment_scheduler_schedule_from_proposal
      
      if @current_user && @current_user.has_role?(:appointment_scheduler)
        @serialize_on_success = 
        {

        }
        @serialize_on_error =
        {
          methods: [:errors]
        }
        return true
      end

    end
      
  end
end
