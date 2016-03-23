class ComposerFor::Admin::PriceCategories::Update

  include Services::PubSubBus::Publisher

  def initialize(price_category, attributes, controller)
    @price_category = price_category
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
    @permitted_attributes = AttributesPermitter::Admin::PriceCategories::Update.new(@attributes).get_permitted
    @price_category.attributes = @permitted_attributes
  end

  def validate
    ModelValidator::Admin::PriceCategory::Create.validate!(@price_category)
  end

  def compose
    
    ActiveRecord::Base.transaction do
      
      @price_category.save!

      @transaction_success = true

    end

    if @transaction_success
      publish(:ok, @price_category)
    end

    rescue Exception => e

    handle_transaction_fail(e)

  end

  def handle_transaction_fail(e)
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @price_category)
    else
      raise e
    end
    
  end

  def clear
    unsubscribe_all
  end

end