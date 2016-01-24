class ComposerFor::Appointment::AppointmentScheduler::ScheduleFromProposal

  include Services::PubSubBus::Publisher

  def initialize(appointment, appointment_attributes)

    @appointment = appointment

    attrs = appointment_attributes

    @appointment.patient_id = attrs[:patient_id]
    @appointment.doctor_id = attrs[:doctor_id]
    @appointment.start_date = attrs[:start_date]
    @appointment.end_date = attrs[:end_date]
    
  end

  def run
    validate
    run_subscriptions
    compose
    clear   
  end

  def validate
    ModelValidator::Appointment::ScheduleFromProposal.validate!(@appointment)
  end

  def run_subscriptions
    subscribe(:on_appointment_created, AppointmentAvailability)
  end

  def compose
    ActiveRecord::Base.transaction do
      
      @appointment.scheduled = true

      @appointment.save!

      publish(:on_appointment_created, @appointment)

      if @appointment.appointment_proposal_infos.destroy_all
        @transaction_success = true
      end

    end
    
    handle_transaction_success

    rescue Exception => e
        handle_transaction_fail(e)
    
  end

  def handle_transaction_unexpected_fail(e)
    raise e
  end

  def handle_transaction_success
    if @transaction_success
      publish(:ok, @appointment)
    end
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