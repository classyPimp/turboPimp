class AppointmentProposalInfo < ActiveRecord::Base
  
  
  belongs_to :appointment
  belongs_to :si_doctor1id, ->{ select(:id) }, class_name: "User", foreign_key: "doctor_id"

end
