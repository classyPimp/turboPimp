class AppointmentProposalInfo < Model
  attributes :anytime_for_date, :id, :date_from, :date_to
  has_one :doctor
  has_one :patient
end