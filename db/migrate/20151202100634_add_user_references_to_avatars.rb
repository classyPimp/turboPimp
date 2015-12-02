class AddUserReferencesToAvatars < ActiveRecord::Migration
  def change
    add_reference :avatars, :user, index: true, foreign_key: true
  end
end
