class OfferedService < ActiveRecord::Base
  
  #ASSOCIATIONS

  belongs_to :user

  has_many :price_items, dependent: :nullify
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
