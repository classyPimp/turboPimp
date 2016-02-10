class ModelValidator::Admin::PriceItem::Create

  def self.validate!(price_item, attributes_that_were_assigned)

    self.new(price_item, attributes_that_were_assigned).validate!
    
  end

  def initialize(price_item, attributes_that_were_assigned)
    @model = price_item
    @attributes_that_were_assigned = attributes_that_were_assigned
  end


  def validate!
    validate_name
    validate_price
    validate_price_category_id
  end

  def validate_name
    
    if @model.name.blank?
      @model.custom_errors[:name] = 'name of category should be provided' and return
    end
  
  end

  def validate_price
    
    if @model.price.blank?
      @model.custom_errors[:price] = 'price must be set' and return
    end
    
    unless @attributes_that_were_assigned["price"].try(:to_i).is_a?(Integer)
      @model.custom_errors[:price] = 'price should be a number'
    end

    if !@model.price.try(:to_i).is_a?(Integer)
      @model.custom_errors[:price] = 'price should be a number'
    end

  end

  def validate_price_category_id
    if @model.price_category_id.blank?
      raise "#{self.class.name}model#{@model} doesnt have price_category_id set on it on create"
    end
  end

end