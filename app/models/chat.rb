class Chat < ActiveRecord::Base

  def self.arbitrary
    @arbitrary ||= {}
  end

  #============== ASSOCIATIONS ================
  
  has_many :chat_messages, dependent: :destroy

  has_many :si_chat_messages1after_id, ->{where('id > ?', Chat.arbitrary[:last_id_for_polling])}, class_name: 'ChatMessage'

  belongs_to :user

  belongs_to :si_user1id_email_registered, ->{select(:id, :email, :registered)}, class_name: 'User', foreign_key: 'user_id'

  #============== END ASSOCIATIONS ============

  #---------------  SCOPES  ===================



  #============== END SCOPES  =================
end
