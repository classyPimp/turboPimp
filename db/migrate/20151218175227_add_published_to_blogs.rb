class AddPublishedToBlogs < ActiveRecord::Migration
  def change
    add_column :blogs, :published, :boolean
    add_column :blogs, :published_at, :datetime
  end
end
