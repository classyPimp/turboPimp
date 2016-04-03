class PriceItem < ActiveRecord::Base

  include Services::CustomErrorable

  #====================== ASSOCIATIONS =================

  belongs_to :price_category

  belongs_to :offered_service
  belongs_to :si_offered_service1id_slug, ->{select(:id, :slug)}, class_name: 'OfferedService', foreign_key: 'offered_service_id'

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
