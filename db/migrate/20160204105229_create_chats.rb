class CreateChats < ActiveRecord::Migration
  def change
    create_table :chats do |t|
      t.integer :chat_messages_count

      t.timestamps null: false
    end
  end
end
