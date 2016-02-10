class ModelValidator::Admin::PriceCategory::Create

  def self.validate!(price_category)
    self.new(price_category).validate!    
  end

  def initialize(price_category)
    @model = price_category
  end

  def validate!
    validate_name
  end

  def validate_name
    
    if @model.name.blank?
      @model.custom_errors[:name] = 'name of category should be provided' and return
    end
  
  end

end