 class ComposerFor::Admin::PriceCategories::Create

  include Services::PubSubBus::Publisher

  def initialize(permitted_attributes)
    @price_category = PriceCategory.new
    @permitted_attributes = permitted_attributes  
  end

  def run
    prepare_attributes
    validate
    compose
    clear   
  end

  def prepare_attributes
    @price_category.attributes = @permitted_attributes
  end

  def validate
    ModelValidator::Admin::PriceCategory::Create.validate!(@price_category)
  end

  def compose

    ActiveRecord::Base.transaction do
      begin

        @price_category.save!

        @transaction_success = true
        
      rescue Exception => e
        handle_transaction_fail(e)
      end

    end

    if @transaction_success
      publish(:ok, @price_category)
    end 
    
  end

  def handle_transaction_fail(e)
    case e
    when ActiveRecord::RecordInvalid
      publish(:fail, @price_category)
    else
      raise e  
    end
  end


  def clear
    unsubscribe_all
  end

end