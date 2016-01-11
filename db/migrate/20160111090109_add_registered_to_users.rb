class AddRegisteredToUsers < ActiveRecord::Migration
  def change
    add_column :users, :registered, :boolean, default: true
  end
end
