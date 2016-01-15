 class ComposerFor::Appointment::Proposal::CreateByRegisteredUser

  include Services::PubSubBus::Publisher

  def initialize(apointment, permitted_attributes, user_id)
    @appointment = appointment  
  end

  def run
    prepare_attributes
    compose
    clear   
  end

  def prepare_attributes
    @appointment.attributes = permitted_attributes
    @appointment.patient_id = user_id
    @appointment.proposal = true
  end

  def compose

  	if @appointment.save
  		publish(:ok, @appointment)
  	else
  		publish(:fail, @appointment)
  	end  	
    
  end

  def clear
    unsubscribe_all
  end

end