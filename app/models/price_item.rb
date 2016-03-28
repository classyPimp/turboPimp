class PriceItem < ActiveRecord::Base

  include Services::CustomErrorable

  #====================== ASSOCIATIONS =================

  belongs_to :price_category

  belongs_to :offered_service

  #====================== END ASSOCITAIONS =============

  def validate_name
    unless name.length > 0
      add_error :name, 'name of the price item shall be provided'
    end

    unless price.to_i > 0
      add_error :price, 'price should be a number'
    end
  end


end
