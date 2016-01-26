class ComposerFor::AppointmentScheduler::Users::CreatePatient

  include Services::PubSubBus::Publisher

  def initialize(user_attributes)

    @user = User.new

    @user_attributes = user_attributes

    @user.attributes = @user_attributes

    @generated_password = rand.to_s[2..11]

    @user.password = @generated_password
    @user.password_confirmation = @generated_password

    @user.registered = true
    
  end

  def run
    validate
    compose
    clear   
  end

  def validate
    ModelValidator::User::CreatePatient.validate!(@user)
  end

  def compose

      ActiveRecord::Base.transaction do  
        begin 
          @user.save!

          @user.add_role :patient

          @transaction_success = true

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