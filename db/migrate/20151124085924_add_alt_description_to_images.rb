class AddAltDescriptionToImages < ActiveRecord::Migration
  def change
    add_column :images, :alt, :string
    add_column :images, :description, :string
  end
end