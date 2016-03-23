class Admin::PriceItemsController < ApplicationController

  def create
    
    perms_for PriceItem
    auth! @perms.admin_create

    permitted_attributes = AttributesPermitter::Admin::PriceItems::Create.new(params).get_permitted

    cmpsr = ComposerFor::Admin::PriceItems::Create.new(permitted_attributes)

    cmpsr.when(:ok) do |price_item|
      render json: price_item.as_json(@perms.serialize_on_success)
    end

    cmpsr.when(:fail) do |price_item|
      render json: price_item.as_json(@perms.serialize_on_error)      
    end

    cmpsr.run

  end

  def destroy
    
    perms_for PriceItem
    auth! @perms.admin_destroy

    @price_item = PriceItem.find(params['id'])

    if @price_item.destroy
      render json: @price_item.as_json()
    else
      head 500
    end

  end


  def update

    perms_for PriceItem

    auth! @perms.admin_update

    @price_item = PriceItem.find(params[:id])

    cmpsr = ComposerFor::Admin::PriceItems::Update.new(@price_item, params[:price_item], self)

    cmpsr.when(:ok) do |price_item|
      render json: price_item.as_json(@perms.serialize_on_success)
    end

    cmpsr.when(:validation_error) do |price_item|
      render json: price_item.as_json(@perms.serialize_on_error)
    end

    cmpsr.run

  end

end
