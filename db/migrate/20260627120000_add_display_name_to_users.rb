class AddDisplayNameToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :display_name, :string
  end
end
