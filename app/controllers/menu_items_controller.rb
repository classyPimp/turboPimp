class MenuItemsController < ApplicationController

  def index
    @menu_items = MenuItem.includes(:menu_items).find(1)
    render json: @menu_items
  end

  def update
    @menu_item.find(1)
    if @menu_item.upate(update_params)
      render json: @menu_item
    end
  end

private

  def update_params
    params.require(:menu_item).permit(:href, :link_text, menu_items_attributes: [:href, :link_text, menu_items: [:href, :link_text]])
  end

end
