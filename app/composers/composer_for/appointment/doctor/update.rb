class ComposerFor::Appointment::Doctor::Update

  include Services::PubSubBus::Publisher

  def initialize(appointment, attributes)
    @appointment = appointment
    @attributes = attributes
  end

  def run
    compose
    clear   
  end

  def subscriptions_after_appointment_updated
    if @appointment.start_date_or_end_date_changed?
      subscribe(:on_appointment_updated, AppointmentAvailability)
    end
  end

  def compose
    
    ActiveRecord::Base.transaction do
      
      @appointment.update!(@attributes)
      
      subscriptions_after_appointment_updated

    end

    publish(:on_appointment_updated, @appointment)
    
    handle_transaction_success

    rescue Exception => e
        handle_transaction_fail(e)
    
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
      handle_transaction_unexpected_fail(e)             
    end
  end

  def clear
    unsubscribe_all
  end

end