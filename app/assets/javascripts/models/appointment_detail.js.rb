class AppointmentDetail < Model

  attributes :id, :appointment_id, :note, :proposal_info
  attributes_as_json_fields :proposal_info

end