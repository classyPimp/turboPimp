class Page < ActiveRecord::Base

  resourcify

  extend FriendlyId
  friendly_id :title, use: :slugged


  belongs_to :user

  validates :body, presence: true, length: { minimum: 6 }

end
