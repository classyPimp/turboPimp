class ModelValidator::Admin::PriceCategory::Create

  def self.validate!(appointment)
    self.new(appointment).validate!    
  end

  def initialize(appointment)
    @model = appointment
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