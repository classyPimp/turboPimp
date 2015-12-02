class AddAttachmentFileToAvatars < ActiveRecord::Migration
  def self.up
    change_table :avatars do |t|
      t.attachment :file
    end
  end

  def self.down
    remove_attachment :avatars, :file
  end
end
