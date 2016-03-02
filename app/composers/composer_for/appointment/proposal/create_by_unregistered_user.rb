class ComposerFor::Appointment::Proposal::CreateByUnregisteredUser

  include Services::PubSubBus::Publisher

  def initialize(appointment, permitted_attributes, user_permitted_attributes)
    @appointment = appointment
    @appointment_permitted_attributes = permitted_attributes 
    @user_permitted_attributes = user_permitted_attributes
  end

  def run
    prepare_attributes
    validate
    compose
    clear   
  end

  def prepare_attributes
    @appointment.attributes = @appointment_permitted_attributes
    @appointment.proposal = true
  end

  def validate
    ModelValidator::Appointment::ProposalCreate.validate!(@appointment)
  end

  def compose
    ActiveRecord::Base.transaction do
  
      begin

        user = ::User.new

        user_cmpsr = ComposerFor::User::Unregistered::Create.new(user, @user_permitted_attributes, ['patient', 'from_proposal'])  

        user_cmpsr.when(:ok) do |user|
          @appointment.patient_id = user.id
          @appointment.scheduled = false
          @appointment.save!
        end

        user_cmpsr.when(:fail) do |user|
          publish(:fail_unregistered_user_validation, user)
          @transaction_success = false
          raise ActiveRecord::Rollback
        end

        user_cmpsr.run

        
        transaction_result

      rescue Exception => e
        
        handle_transaction_fail(e)

      end

    end

    
  
  end

  def transaction_result

    handle_transaction_success unless @transaction_success == false
    
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
    else
      handle_transaction_unexpected_fail(e)             
    end
  end

  def clear
    unsubscribe_all
  end
end