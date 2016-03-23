class ComposerFor::User::RegularDestroy

  include Services::PubSubBus::Publisher 

  def initialize(user)
    @user = user
  end

  def run
    compose
    clear
  end

  def compose

    ActiveRecord::Base.transaction do
      
      @user.destroy!
      
    end

    handle_transaction_success

    rescue Exception => e
      handle_transaction_fail(e)

  end

  def clear
    unsubscribe_all
  end

  def handle_transaction_success
    publish(:ok, @user)
  end

  def handle_transaction_fail(e)
    publish(:fail, @user)
  end

end