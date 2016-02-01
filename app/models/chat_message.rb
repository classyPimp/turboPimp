class ChatMessage < ActiveRecord::Base
  belongs_to :user
  belongs_to :recepient, class_name: 'User', foreign_key: 'to_user'
end
