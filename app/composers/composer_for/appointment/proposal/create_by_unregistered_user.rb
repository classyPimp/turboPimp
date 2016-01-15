class ComposerFor::Appointment::Proposal::CreateByUnregisteredUser

  include Services::PubSubBus::Publisher

  def initialize(appointment, permitted_attributes, user_permitted_attributes)
    @appointment = appointment
    @user_permitted_attributes = user_permitted_attributes
  end

  def run
    prepare_attributes
    compose
    clear   
  end

  def prepare_attributes
    @appointment.attributes = @user_permitted_attributes
    @appointment.proposal = true
  end

  def compose
    ActiveRecord::Base.transaction do
      
      user = User.new

      user_cmpsr = ComposerFor::User::Unregistered::Create.new(user, @user_permitted_attributes)

      user_cmpsr.when(:ok) do |user|
        @appointment.patient_id = user.id
        @appointment.save!
      end

      user_cmpsr.when(:fail) do |user|
        raise ActiveRecord::Rollback
        publish(:fail_unregistered_user_validation, user)
      end

      user_cmpsr.run

      @transaction_success = true

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