class ProposalInfo < Model
  #IS json field for AppointmentDetail
  attributes :preferred_primary, :any_time_for_date, :user_contact_info
  attributes_as_json_fields :user_contact_info
end