class Admin::PriceCategoriesController < ApplicationController

  def create
    
    perms_for PriceCategory
    auth! @perms.admin_create

    permitted_attributes = AttributesPermitter::Admin::PriceCategories::Create.new(params).get_permitted

    cmpsr = ComposerFor::Admin::PriceCategories::Create.new(permitted_attributes)

    cmpsr.when(:ok) do |price_category|
      render json: price_category.as_json(@perms.serialize_on_success)
    end

    cmpsr.when(:fail) do |price_category|
      render json: price_category.as_json(@perms.serialize_on_error)
    end

    cmpsr.run

  end

  def index
    
    perms_for PriceCategory
    auth! @perms.admin_index

    @price_categories = PriceCategory.all.includes(:price_items)

    render json: @price_categories.as_json(@perms.serialize_on_success)

  end

  def destroy
    
    perms_for PriceCategory
    auth! @perms.admin_destroy

    @price_category = PriceCategory.find(params[:id])

    if @price_category.destroy
      render json: @price_category.as_json
    else
      head 500
    end

  end

  def update
    
    perms_for PriceCategory

    auth! @perms.admin_update

    @price_category = PriceCategory.find(params[:id])

    cmpsr = ComposerFor::Admin::PriceCategories::Update.new(@price_category, params[:price_category], self)

    cmpsr.when(:ok) do |price_category|
      render json: price_category.as_json(@perms.serialize_on_success)
    end

    cmpsr.when(:validation_error) do |price_category|
      render json: price_category.as_json(@perms.serialize_on_error)
    end

    cmpsr.run

  end

end
