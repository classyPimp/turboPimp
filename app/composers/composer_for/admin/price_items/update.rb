class ComposerFor::Admin::PriceItems::Update

  include Services::PubSubBus::Publisher

  def initialize(price_item, attributes, controller)
    @price_item = price_item
    @attributes = attributes
    @controller = controller
  end

  def run
    prepare_attributes
    validate
    compose
    clear
  end

  def prepare_attributes
    @permitted_attributes = AttributesPermitter::Admin::PriceItems::Update.new(@attributes).get_permitted
    @price_item.attributes = @permitted_attributes
  end

  def validate
    ModelValidator::Admin::PriceItem::Create.validate!(@price_item, @permitted_attributes)
  end

  def compose
    
    ActiveRecord::Base.transaction do
      
      @price_item.save!

      @transaction_success = true

    end

    if @transaction_success
      publish(:ok, @price_item)
    end

    rescue Exception => e

    handle_transaction_fail(e)

  end

  def handle_transaction_fail(e)
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @price_item)
    else
      raise e
    end
    
  end

  def clear
    unsubscribe_all
  end

end