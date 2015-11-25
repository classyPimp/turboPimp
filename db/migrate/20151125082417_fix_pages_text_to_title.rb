class FixPagesTextToTitle < ActiveRecord::Migration
  def change
    rename_column :pages, :text, :title
  end
end