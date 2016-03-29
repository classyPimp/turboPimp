class CreateOfferedServiceAvatars < ActiveRecord::Migration
  def change
    create_table :offered_service_avatars do |t|
      t.references :offered_service, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
