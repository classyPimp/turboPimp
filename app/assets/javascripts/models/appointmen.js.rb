class Appointment < Model

  attributes :id, :start_date, :end_date, :patient_id, :doctor_id, :user_id, :scheduled
  has_one :appointment_detail, :patient
  accepts_nested_attributes_for :appointment_detail


  route "Show", get: "appointments/:id"

  route "update", {put: "appointments/:id"}, {defaults: [:id]}

  route "create", post: "appointments"

  route "Index", get: "appointments"
  
  route "destroy", {delete: "appointments/:id"}, {defaults: [:id]} 

  route "Edit", {get: "appointments/:id/edit"}

  def validate_start
    unless Date.parse(self.start)
      add_error :date, "should provide a valid date"
    end
  end

  def validate_patient_id
    unless patient_id.to_i.is_a? Integer
      add_error :patient_id, "you should choose a patient"
    end
  end  
end