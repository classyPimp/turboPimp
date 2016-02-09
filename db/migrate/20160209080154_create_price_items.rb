class CreatePriceItems < ActiveRecord::Migration
  def change
    create_table :price_items do |t|
      t.references :price_category, index: true, foreign_key: true
      t.text :name
      t.decimal :price, precision: 6, scale: 2
      t.text :details

      t.timestamps null: false
    end
  end
end
