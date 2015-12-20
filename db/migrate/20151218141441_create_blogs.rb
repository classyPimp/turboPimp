class CreateBlogs < ActiveRecord::Migration
  def change
    create_table :blogs do |t|
      t.references :user, index: true, foreign_key: true
      t.string :title
      t.text :body
      t.string :m_title
      t.string :m_description
      t.string :m_keywords
      t.string :slug

      t.timestamps null: false
    end
  end
end
