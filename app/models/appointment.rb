  class Appointment < ActiveRecord::Base

  #_--------------ASSOCIATIONS
  belongs_to :user
  belongs_to :doctor, class_name: "User"
  belongs_to :patient, ->{select(:id)}, class_name: "User"
  has_one :appointment_detail, dependent: :destroy

  accepts_nested_attributes_for :appointment_detail, allow_destroy: true, reject_if: :all_blank 


#===================VALIDATIONS
  
  validates :patient_id, presence: true, numericality: { only_integer: true }
  validate :validate_patient_id
  validates :doctor_id, presence: true, numericality: {only_integer: true}
  validate :validate_doctor_id

  def validate_patient_id
    if patient_id.present?
      errors.add(:patient_id, "is invalid") unless (
        (x = User.select(:id).find(patient_id)) && x.has_role?(:patient)
      )
    end
  end

  def validate_doctor_id
    if doctor_id.present?
      errors.add(:doctor_id_id, "is invalid") unless (
        x = User.select(:id).find(doctor_id) and x.has_role?(:doctor)
      )
    end
  end
  
#============== CALLBACKS

  after_create :configure_appointment_availability

  def configure_appointment_availability
    AppointmentAvailability.configure_appointment_availability(self)
  end

end
