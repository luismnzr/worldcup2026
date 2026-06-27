class AddFeaturedToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :featured, :boolean, default: false, null: false
  end
end
