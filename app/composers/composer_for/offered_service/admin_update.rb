class ComposerFor::OfferedService::AdminUpdate  

  include Services::PubSubBus::Publisher

  def initialize(model, params, controller)
    @model = model
    @params = params
    @controller = controller

    @associated_price_item_params = @params['offered_service']['price_items'] || []
  end

  def run
    convert_simulated_arrays_in_params
    prepare_attributes
    #validate
    compose
    clear
  end 

  def convert_simulated_arrays_in_params
    @associated_price_item_params = @controller.simulated_array_to_a(@associated_price_item_params)
  end

  def prepare_attributes
    @permitted_attributes = AttributesPermitter::OfferedService::AdminCreate.new(@params).get_permitted
  end

  def compose

    ActiveRecord::Base.transaction do
      
      assign_attributes

      @model.save!

    end

    handle_transaction_success

    rescue Exception => e
      handle_transaction_fail(e)
  end


  def assign_attributes

    @model.attributes = @permitted_attributes
      
    get_price_items_to_assign

    @price_items.each do |price_item|
      @model.price_items << price_item
    end

    nullify_marked_price_items

  end

  #PRICE ITEM RELATED

  def get_price_items_to_assign
    get_price_items_collection get_price_item_ids
  end


  def get_price_items_collection(ids)
    @price_items = PriceItem.where('id in (?)', ids).select(:id)
  end

  def get_price_item_ids
    price_item_ids = []
    
    
    @associated_price_item_params.each do |_price_item|
      if !_price_item['price_item']['_destroy'] && _price_item['price_item']['id']
        price_item_ids << _price_item['price_item']['id']
      end  
    end
    
    price_item_ids
  end

  def nullify_marked_price_items
    price_items_to_nullify = []

    @associated_price_item_params.each do |_price_item|
      if _price_item['price_item']['_destroy'] && _price_item['price_item']['id']
        price_items_to_nullify << _price_item['price_item']['id']
      end  
    end

    price_items = PriceItem.where('id in (?)', price_items_to_nullify).select(:id, :offered_service_id)

    price_items.each do |price_item|
      price_item.offered_service_id = nil
      price_item.save!
      
    end
  end

  #END PRICE ITEM RELATED
    
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

