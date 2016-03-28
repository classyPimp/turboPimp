class CreateOfferedServices < ActiveRecord::Migration
  def change
    create_table :offered_services do |t|
      t.text :body
      t.string :title
      t.string :m_title
      t.string :m_description
      t.string :m_keywords
      t.string :slug
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
