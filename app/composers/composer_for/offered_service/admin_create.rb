class ComposerFor::OfferedService::AdminCreate 

  include Services::PubSubBus::Publisher

  def initialize(model, params, controller)
    @model = model
    @params = params
    @controller = controller

    @associated_price_item_params = @params['offered_service']['price_items'] || []
  end

  def run
    prepare_attributes
    #validate
    compose
    clear
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

    @model.user_id = @controller.current_user.id

    create_and_assign_avatar

  end

  def create_and_assign_avatar
    byebug
    return unless @params[:offered_service][:avatar][:offered_service_avatar][:avatar]

    cmpsr = ::ComposerFor::OfferedServiceAvatar::Create.new(::OfferedServiceAvatar.new, @params[:offered_service][:avatar], @controller)

    cmpsr.when(:ok) do |avatar|
      @model.avatar = avatar
    end

    cmpsr.when(:validation_fail) do |avatar|
      raise "avatar validation fail"
    end

    cmpsr.run

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
    byebug
    price_item_ids
  end

  #END PRICE ITEM RELATED
    
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
      raise "unexpected"          
    end
  end

  def clear
    unsubscribe_all
  end

end

