class Chat < Model

  attributes :id, :user_id
  has_many :chat_messages
  has_one :user

end