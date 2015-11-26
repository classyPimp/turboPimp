class MenuItem < ActiveRecord::Base
  belongs_to :menu_item
  has_many :menu_items, dependent: :destroy
  accepts_nested_attributes_for :menu_items, allow_destroy: true
end
