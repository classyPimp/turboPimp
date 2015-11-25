class Page < ActiveRecord::Base

  extend FriendlyId
  friendly_id :title, use: :slugged


  belongs_to :user

  validates :body, presence: true, length: { minimum: 6 }

end
