class PriceItem < ActiveRecord::Base

  #====================== ASSOCIATIONS =================

  belongs_to :price_category

  #====================== END ASSOCITAIONS =============

end
