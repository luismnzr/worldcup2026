class AddNotesToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :notes, :text
  end
end
