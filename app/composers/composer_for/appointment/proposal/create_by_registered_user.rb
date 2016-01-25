 class ComposerFor::Appointment::Proposal::CreateByRegisteredUser

  include Services::PubSubBus::Publisher

  def initialize(appointment, permitted_attributes, user_id)
    @appointment = appointment
    @permitted_attributes = permitted_attributes
    @user_id = user_id  
  end

  def run
    prepare_attributes
    compose
    clear   
  end

  def prepare_attributes
    @appointment.attributes = @permitted_attributes
    @appointment.patient_id = @user_id
    @appointment.proposal = true
    @appointment.scheduled = false
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