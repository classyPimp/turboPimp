class AddAttachmentAvatarToOfferedServiceAvatars < ActiveRecord::Migration
  def self.up
    change_table :offered_service_avatars do |t|
      t.attachment :avatar
    end
  end

  def self.down
    remove_attachment :offered_service_avatars, :avatar
  end
end
