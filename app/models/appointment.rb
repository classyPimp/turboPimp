class Appointment < ActiveRecord::Base

  
  # I find some conditional validations can become unmanagable mess
  # I use PORO validation classes for different scenarios (e.g. save_as_proposal) that adds errors
  #but the problem is that Rails ignore otside added errors (that's totally reasonable), with this accessor
  #PORO validation classes do add errors to @custom_errors, and rails has validate :custom_errors (or any other) which would duplicate and 
  #add error in callback, which would allow to raise RecorInvalid on save! if !custom_errors.empty?
  include Services::CustomErrorable


  @arbitrary = {}

  class << self

    attr_accessor :arbitrary

  end

  def arbitrary
    @arbitrary ||= {}
  end

  ###################################################
  #_--------------ASSOCIATIONS
  belongs_to :user

  belongs_to :doctor, class_name: "User"

  belongs_to :patient, ->{select(:id, :registered)}, class_name: "User", foreign_key: 'patient_id'

  has_one :appointment_detail, dependent: :destroy
  has_one :si_appointment_detail1extra_details, ->{select(:id, :extra_details, :appointment_id)},class_name: 'AppointmentDetail'

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
      },
      :si_appointment_detail1extra_details                                  
    ) 
  }
  
#================================
#===================VALIDATIONS
  
  validates :patient_id, presence: true, numericality: { only_integer: true }
  validate :validate_patient_id, unless: ->{ arbitrary[:skip_validate_patient_id] }
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
