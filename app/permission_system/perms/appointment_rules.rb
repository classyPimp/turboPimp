module Perms
  class AppointmentRules < Perms::Base


    def create
      if @current_user && @current_user.has_role?(:doctor)

        @permitted_attributes = params.require(:appointment).
          permit(:start_date, :end_date, :patient_id, appointment_detail_attributes: [:note])

        @permitted_attributes[:doctor_id] = @current_user.id
        @permitted_attributes[:scheduled] = true
        @permitted_attributes[:user_id] = @current_user.id
def change
rename_column :table_name, :old_column, :new_column
end
        @serialize_on_success = {include: [patient: {root: true, include: [profile: {root: true}]}]}
        @serialize_on_error = {methods: [:errors]}
        
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
      
  end
end