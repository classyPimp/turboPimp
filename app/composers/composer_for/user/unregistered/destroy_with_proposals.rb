class ComposerFor::User::Unregistered::DestroyWithProposals


  #STOPPED ON INCLUDING PUBSUBBUS
  include Pu

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
             
        appointments.each do |appointment|
          appointment_destroy_cmpsr = ComposerFor::Appointment::Doctor::Destroy(appointment)
        end

        appointment_destroy_cmpsr.when(:ok) do |appointment|
          @user.destroy!
          @transaction_success = true
        end

        appointment_destroy_cmpsr.when(:fail) do |appointment|
          raise "unexpected"
        end

        cmpsr.run

    end

    handle_transaction_success

    rescue Exception => e
      handle_transaction_fail(e)

  end

  def handle_transaction_success
    publish(:ok, @user) if @transaction_success
  end

  def handle_transaction_fail(e)
    publish(:fail)
  end

end