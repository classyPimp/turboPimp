class ComposerFor::User::Unregistered::DestroyWithProposals

  include Services::PubSubBus::Publisher 

  def initialize(user)
    @user = user
  end

  def run
    compose
    clear
  end

  def compose
    appointments = Appointment.where(id: @user.si_appointments_as_patient1id.map(&:id))

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