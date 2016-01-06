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

  after_create :on_appointment_created
  after_destroy :on_appointment_destroyed
  after_update :on_appointment_updated
  
  def on_appointment_created
    self.sub_to(:on_appointment_created, AppointmentAvailability)
    self.pub_to(:on_appointment_created, self)
    self.unsub_from(:on_appointment_created, AppointmentAvailability)
  end

  def on_appointment_destroyed
    self.sub_to(:on_appointment_destroyed, AppointmentAvailability)
    self.pub_to(:on_appointment_destroyed, self)
    self.unsub_from(:on_appointment_destroyed, AppointmentAvailability)
  end

  def on_appointment_updated
    return true unless self.changed.include?("start_date") || self.changed.include?("end_date")

    _changes = []
    _changes[0] = self.changes[:start_date][0].to_formatted_s(:iso8601) if self.changes[:start_date]
    _changes[1] = self.changes[:end_date][0].to_formatted_s(:iso8601) if self.changes[:end_date]

    self.sub_to(:on_appointment_updated, AppointmentAvailability)
    self.pub_to(:on_appointment_updated, self, _changes)
    self.unsub_from(:on_appointment_updated, AppointmentAvailability)
  end

  include Services::PubSubBus
  allowed_channels instance: [:on_appointment_created, :on_appointment_updated, :on_appointment_destroyed]

end
