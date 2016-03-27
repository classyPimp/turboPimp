class Chat < Model

  attributes :id, :user_id, :user
  has_many :chat_messages
  has_one :user

  route "destroy", {delete: "chats/:id"}, {defaults: [:id]}


end