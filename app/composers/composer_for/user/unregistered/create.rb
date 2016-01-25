 class ComposerFor::User::Unregistered::Create

  include Services::PubSubBus::Publisher

  def initialize(user, permitted_attributes)
    @user = user
    @permitted_attributes = permitted_attributes  
  end

  def run
    prepare_attributes
    compose
    clear   
  end

  def prepare_attributes
    User.arbitrary[:register_as_guest] = true
    @user.attributes = @permitted_attributes
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

    if @transaction_success
      publish(:ok, @user)
    end 
    
  end

  def handle_transaction_fail(e)
    case e
    when ActiveRecord::RecordInvalid
      publish(:fail, @user)
    else
      raise e  
    end
  end


  def clear
    unsubscribe_all
  end

end