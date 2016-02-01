class AddReadToChatMessages < ActiveRecord::Migration
  def change
    add_column :chat_messages, :read, :boolean
  end
end
