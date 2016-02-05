class AddChatMessagesCounterToChats < ActiveRecord::Migration
  def change
    add_column :chats, :unread_count, :integer
  end
end
