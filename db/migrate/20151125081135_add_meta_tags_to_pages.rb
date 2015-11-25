class AddMetaTagsToPages < ActiveRecord::Migration
  def change
    add_column :pages, :m_title, :string
    add_column :pages, :m_description, :string
    add_column :pages, :m_keywords, :string
  end
end