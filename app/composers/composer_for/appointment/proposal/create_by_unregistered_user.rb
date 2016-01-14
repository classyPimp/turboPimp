class ComposerFor::Appointment::Proposal::CreateByUnregisteredUser

  include Services::PubSubBus::Publisher

  def initialize(appointment, unregistered_user_permitted_attributes)
    @appointment = appointment
    @unregistered_user_permitted_attributes = unregistered_user_permitted_attributes
    byebug
  end

  def run
    compose
    clear   
  end

  def compose
    ActiveRecord::Base.transaction do
      
      user = User.new(@unregistered_user_permitted_attributes)
      cmpsr = ComposerFor::User::Unregistered::Create.new(user)

      cmpsr.when(:ok) do |user|
        @appointment.patient_id = user
        @appointment.save!
      end

      cmpsr.when(:fail) do |user|
        publish(:fail_unregistered_user_validation, user) and return
      end

      cmpsr.run

    end
    
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