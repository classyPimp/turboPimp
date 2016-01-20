class Appointment < ActiveRecord::Base

  #_--------------ASSOCIATIONS
  belongs_to :user

  belongs_to :doctor, class_name: "User"

  belongs_to :patient, ->{select(:id)}, class_name: "User"

  has_one :appointment_detail, dependent: :destroy

  has_many :appointment_proposal_infos, dependent: :destroy
  has_many :si_appointment_proposal_infos1all, class_name: "AppointmentProposalInfo"


  accepts_nested_attributes_for :appointment_detail, allow_destroy: true
  
  accepts_nested_attributes_for :appointment_proposal_infos, allow_destroy: true, reject_if: :all_blank 

#=====================SCOPES
  scope :unscheduled_with_doctors_and_proposal_infos, ->{ 
    where(scheduled: false).includes(
      {
        si_appointment_proposal_infos1all: 
        [
          {
            si_doctor1id: [:si_profile1id_name]
          }
        ]
      },
      {
        patient: [:si_profile1name_phone_number]
      }                                  
    ) 
  }
  
#================================
#===================VALIDATIONS
  
  validates :patient_id, presence: true, numericality: { only_integer: true }
  validate :validate_patient_id
  validates :doctor_id, presence: true, numericality: {only_integer: true}, unless: -> { self.proposal } 
  validate :validate_doctor_id, unless: -> { self.proposal }
  validate :validate_start_date_to_be_valid_date, on: :create 

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

  def validate_start_date_to_be_valid_date 
    unless start_date.is_a?(ActiveSupport::TimeWithZone) || start_date.is_a?(Date) 
      errors.add(:start_date, "is invalid")
    end
  end
  
#============== Methods used from outside
  
  def start_date_or_end_date_changed?
    self.previous_changes.include?("start_date") || self.previous_changes.include?("end_date")
  end

  def changes_of_start_date_and_end_date
    _changes = []
    _changes[0] = self.previous_changes[:start_date][0].to_formatted_s(:iso8601) if self.previous_changes[:start_date]
    _changes[1] = self.previous_changes[:end_date][0].to_formatted_s(:iso8601) if self.previous_changes[:end_date]
    _changes
  end

end
