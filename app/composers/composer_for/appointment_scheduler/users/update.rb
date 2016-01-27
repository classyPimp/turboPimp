class ComposerFor::AppointmentScheduler::Users::Update

  include Services::PubSubBus::Publisher

  def initialize(user, user_attributes)

    @user = user

    @user.attributes = user_attributes

  end

  def run
    validate
    compose
    clear   
  end

  def validate
    ModelValidator::AppointmentScheduler::Users::Update.validate!(@user)
  end

  def compose

      ActiveRecord::Base.transaction do  
        begin 
          
          @user.save!

        rescue Exception => e
          handle_transaction_fail(e)
        end
      end
      
      handle_transaction_success

    
  end

  def handle_transaction_unexpected_fail(e)
    raise e
  end

  def handle_transaction_success
    if @transaction_success
      publish(:ok, @user)
    end
  end

  def handle_transaction_fail(e)
    case e
    when ActiveRecord::RecordInvalid
      publish(:fail, @user)
    else
      handle_transaction_unexpected_fail(e)             
    end
  end

  def clear
    unsubscribe_all
  end

end