class ComposerFor::AppointmentScheduler::Users::Update

  include Services::PubSubBus::Publisher

  def initialize(user, user_attributes)

    @user = user

    if user_attributes[:profile_attributes] && @user.profile
      if !!user_attributes[:id]
        raise "no id provided for existing profile #{self.class.name}"
      end
    end

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
          @user.arbitrary[:no_password_update] = true
          
          if @user.email.blank?
            @user.arbitrary[:skip_email_validation] = true 
          end

          @user.save!

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
    else
      raise "unexpected fail #{self.class.name}"
    end
  end

  def handle_transaction_fail(e)
    byebug
    case e
    when ActiveRecord::RecordInvalid
      publish(:fail, @user)
    else
      handle_transaction_unexpected_fail(e)             
    end
  end

  def clear
    @user.arbitrary.delete(:no_password_update)
    unsubscribe_all
  end

end