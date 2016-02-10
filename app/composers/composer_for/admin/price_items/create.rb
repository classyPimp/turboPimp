 class ComposerFor::Admin::PriceItems::Create

  include Services::PubSubBus::Publisher

  def initialize(permitted_attributes)
    @price_item = PriceItem.new
    @permitted_attributes = permitted_attributes  
  end

  def run
    prepare_attributes
    validate
    compose
    clear   
  end

  def prepare_attributes
    @price_item.attributes = @permitted_attributes
  end

  def validate
    
    ModelValidator::Admin::PriceItem::Create.validate!(@price_item, @permitted_attributes)
    
  end

  def compose

    ActiveRecord::Base.transaction do
      begin

        @price_item.save!

        @transaction_success = true
        
      rescue Exception => e
        handle_transaction_fail(e)
      end

    end

    if @transaction_success
      publish(:ok, @price_item)
    end 
    
  end

  def handle_transaction_fail(e)
    case e
    when ActiveRecord::RecordInvalid
      publish(:fail, @price_item)
    else
      raise e  
    end
  end


  def clear
    unsubscribe_all
  end

end