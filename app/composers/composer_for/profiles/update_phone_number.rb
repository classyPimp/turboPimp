class ComposerFor::Profiles::UpdatePhoneNumber   

  include Services::PubSubBus::Publisher

  def initialize(model, params, controller)
    @model = model
    @params = params
    @controller = controller
  end

  def run
    permit_attributes
    assign_attributes
    validate
    compose
    clear
  end

  def permit_attributes
    @permitted_attributes = @params.require(:profile).permit(:phone_number)
  end

  def assign_attributes
    @model.attributes = @permitted_attributes
  end

  def validate
    if @model.phone_number.blank? || !(/\A[+-]?\d+\z/.match(@model.phone_number))
      @model.add_custom_error('phone_number', 'phone number is invalid')
    end
  end

  def compose

    ActiveRecord::Base.transaction do
      
      @model.save!

    end

    handle_transaction_success

    rescue Exception => e
      
      handle_transaction_fail(e)
  end

    
  def handle_transaction_success
    publish(:ok, @model)
  end

  def handle_transaction_fail(e)
    case e
    when ActiveRecord::RecordInvalid
      
      publish(:validation_fail, @model)
    else
      
      raise "unexpected"          
    end
  end

  def clear
    unsubscribe_all
  end

end

