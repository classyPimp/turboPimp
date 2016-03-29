class ComposerFor::OfferedServiceAvatar::Create 

  include Services::PubSubBus::Publisher

  def initialize(model, params, controller)
    @model = model
    @params = params
    @controller = controller
  end

  def run
    prepare_attributes
    #validate
    compose
    clear
  end

  def prepare_attributes
    @permitted_attributes = ::AttributesPermitter::OfferedServiceAvatar::Create.new(@params).get_permitted
  end

  def compose

    ActiveRecord::Base.transaction do
      
      @model.attributes = @permitted_attributes

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
      raise e 
    else
      byebug
      raise 'avatar unexpected fail'            
    end
  end

  def clear
    unsubscribe_all
  end


end