class ChatMessage < ActiveRecord::Base

  #============ ASSOCIATIONS ===========
  
  belongs_to :user
  
  belongs_to :recepient, class_name: 'User', foreign_key: 'to_user'

  belongs_to :chat, counter_cache: true

  #============ END ASSOCIATIONS =======



end
