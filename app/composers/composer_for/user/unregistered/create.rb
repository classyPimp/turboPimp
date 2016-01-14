 class ComposerFor::User::Unregistered::Create

  include Services::PubSubBus::Publisher

  def initialize(user)
    @user = user  
  end

  def run
    compose
    clear   
  end

  def compose
    User.arbitrary = {register_guest: true}
    if @user.save
      User.arbitrary.delete :register_guest
      publish(:ok, @user)
      byebug
    else
      publish(:fail, @user)
      byebug
    end   
    
  end

  def clear
    unsubscribe_all
  end

end