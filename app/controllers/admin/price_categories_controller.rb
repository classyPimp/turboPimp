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

end
