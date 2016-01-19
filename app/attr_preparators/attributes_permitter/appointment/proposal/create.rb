class AttributesPermitter::Appointment::Proposal::Create

  def initialize(params)
    @params = params.require(:appointment)
  end

  def get_permitted
    @permitted_attributes = @params.
      permit(:start_date, appointment_proposal_infos_attributes: [:anytime_for_date, :doctor_id, :date_from, :date_to], appointment_detail_attributes: [:extra_details] )
    @permitted_attributes
  end

end