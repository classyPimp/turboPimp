class MenuItemsController < ApplicationController

  def index
    @menu = MenuItem.includes(menu_items: [:menu_items]).find(1)
    @menu = @menu.as_json(include: {menu_items: {root: true, include: {menu_items: {root: true}}}})
    render json: @menu
  end

  def update
    @menu =  MenuItem.includes(menu_items: [:menu_items]).find(1)
    @menu_items = @menu.as_json(include: {menu_items: {root: true, include: {menu_items: {root: true}}}})
    render json: @menu_items
  end

private

  def update_params
    params.require(:menu_item).permit(:href, :link_text, menu_items_attributes: [:id, :href, :link_text, :_destroy, menu_items_attributes: [:id, :href, :link_text, :_destroy]])
  end

end
