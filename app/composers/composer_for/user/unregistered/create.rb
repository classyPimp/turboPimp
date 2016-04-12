 class ComposerFor::User::Unregistered::Create

  include Services::PubSubBus::Publisher

  def initialize(user, permitted_attributes, roles_to_add)
    @user = user
    @permitted_attributes = permitted_attributes
    role_names = []
    roles_to_add.each do |name|
      role_names << {name: name}
    end
    @permitted_attributes[:roles_attributes] = role_names
  end

  def run
    prepare_attributes
    validate
    compose
    clear   
  end

  def prepare_attributes
    User.arbitrary[:register_as_guest] = true
    @user.arbitrary[:skip_email_validation] = true
    @user.attributes = @permitted_attributes.to_h
  end

  def validate
    if @user.profile.phone_number.blank?
      @user.profile.add_custom_error(:phone_number, 'phone number must be provided')
    end
  end

  def compose

    ActiveRecord::Base.transaction do
      begin

        @user.save!
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