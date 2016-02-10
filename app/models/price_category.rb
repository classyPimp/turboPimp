class PriceCategory < ActiveRecord::Base

  include Services::CustomErrorable

  #====================== ASSOCIATIONS =================

  has_many :price_items

  #====================== END ASSOCITAIONS =============
  
end
