class PriceCategory < ActiveRecord::Base

  include Services::CustomErrorable

  #====================== ASSOCIATIONS =================

  has_many :price_items, dependent: :destroy

  #====================== END ASSOCITAIONS =============
  
end
