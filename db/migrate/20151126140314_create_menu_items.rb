class CreateMenuItems < ActiveRecord::Migration
  def change
    create_table :menu_items do |t|
      t.string :href
      t.string :link_text
      t.references :menu_item, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
