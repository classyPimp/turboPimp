class Page < ActiveRecord::Base
  #ROLIFY
  resourcify
#THIRD PARTY PLUGINS

  extend FriendlyId
  friendly_id :title, use: :slugged

#pg_search
  include PgSearch
  pg_search_scope :search_by_title_body, :against => [:title, :body]

#ASSOCIATIONS
  belongs_to :user

#VALIDATIONS
  validates :body, presence: true, length: { minimum: 6 }

end
