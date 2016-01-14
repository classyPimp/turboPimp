 class ComposerFor::Appointment::Proposal::CreateByRegisteredUser

  include Services::PubSubBus::Publisher

  def initialize(apointment)
    @appointment = appointment  
  end

  def run
    compose
    clear   
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