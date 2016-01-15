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
    @user.attributes = @permitted_attributes
  end

  def compose
   
    User.arbitrary = {register_guest: true}
   
    if @user.save
      User.arbitrary.delete :register_guest
      publish(:ok, @user)
    else
      publish(:fail, @user)
    end   
    
  end

  def clear
    unsubscribe_all
  end

end