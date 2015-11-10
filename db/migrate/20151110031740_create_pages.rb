class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :body
      t.text :text
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
