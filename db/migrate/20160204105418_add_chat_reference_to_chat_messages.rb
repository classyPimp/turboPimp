class AddChatReferenceToChatMessages < ActiveRecord::Migration
  def change
    add_reference :chat_messages, :chat, index: true, foreign_key: true
  end
end
