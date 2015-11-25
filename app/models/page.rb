class Page < ActiveRecord::Base
  belongs_to :user

  validates :body, presence: true, length: { minimum: 6 }

end
