class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.references :user, index: true, foreign_key: true
      t.text :bio
      t.string :position

      t.timestamps null: false
    end
  end
end
