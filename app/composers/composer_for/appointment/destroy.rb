class ComposerFor::Appointment::Destroy

  include Services::PubSubBus::Publisher

  def initialize(appointment)
    @appointment = appointment
  end

  def run
    run_subscriptions
    compose
    clear   
  end

  def run_subscriptions
    subscribe(:on_appointment_destroyed, AppointmentAvailability)
  end

  def compose
    ActiveRecord::Base.transaction do
      
      @appointment.destroy!

      publish(:on_appointment_destroyed, @appointment)
     
    end
    
    handle_transaction_success

    rescue Exception => e
        handle_transaction_fail
  end

  def handle_transaction_unexpected_fail(e)
    raise e
  end

  def handle_transaction_success
    publish(:ok, @appointment)
  end

  def handle_transaction_fail(e)
    case e
    when ActiveRecord::RecordInvalid
      publish(:fail, @appointment)
      raise e 
    else
      handle_transaction_unexpected_fail             
    end
  end

  def clear
    unsubscribe_all
  end

end