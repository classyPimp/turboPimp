class Chat < ActiveRecord::Base
  #============== ASSOCIATIONS ================
  
  has_many :chat_messages

  belongs_to :user

  #============== END ASSOCIATIONS ============
end
