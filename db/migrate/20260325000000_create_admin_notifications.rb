class CreateAdminNotifications < ActiveRecord::Migration[7.2]
  def change
    create_table :admin_notifications do |t|
      t.string :title, null: false
      t.string :body
      t.string :category, null: false
      t.string :action_url
      t.datetime :read_at

      t.timestamps
    end

    add_index :admin_notifications, :category
    add_index :admin_notifications, :read_at
    add_index :admin_notifications, :created_at
  end
end
