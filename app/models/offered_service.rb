class OfferedService < ActiveRecord::Base
  
  #ASSOCIATIONS

  belongs_to :user

  has_one :avatar, dependent: :destroy, class_name: 'OfferedServiceAvatar'

  has_many :price_items, dependent: :nullify
  has_many :si_price_items1id_name_price, ->{select(:id, :name, :price)}, class_name: 'PriceItem'
  #END ASSOCIATIONS

  #FREINDLY ID
  extend FriendlyId
  friendly_id :title, use: :slugged
  #END FRIENDLY ID


  #pg_search
  include PgSearch
  pg_search_scope :search_by_title_body, :against => [:title, :body]
  #END PG_SEARCH
end
