class CreateChatMessages < ActiveRecord::Migration
  def change
    create_table :chat_messages do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :to_user
      t.text :text

      t.timestamps null: false
    end
  end
end
