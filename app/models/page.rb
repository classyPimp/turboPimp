class Page < ActiveRecord::Base
  belongs_to :user

  validates :text, presence: true, length: { minimum: 6 } 
end
