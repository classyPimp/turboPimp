class AppointmentDetail < ActiveRecord::Base
  #proposal_info attribute is serialized and deserialized it is JSON'ed string
  #in order to not cause from malicious users fucking with what gets sent, it should be hard validated
  #it should follow this structure:
  # {
  #   doctor: {#{id of a doctor (user_id taken from AppointmentAvailability)}: [of arrays of [start_date.iso8601, end_date.iso8601]]} <=optional
  #   any_doctor: [of arrays of [start_date.iso8601, end_date.iso8601]]
  #   appointment_purpose: String
  # }


  belongs_to :appointment

end
