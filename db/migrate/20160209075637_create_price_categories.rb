class CreatePriceCategories < ActiveRecord::Migration
  def change
    create_table :price_categories do |t|
      t.text :name

      t.timestamps null: false
    end
  end
end
