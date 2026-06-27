class DropLegacyClassesAndWellhub < ActiveRecord::Migration[7.2]
  def up
    execute "UPDATE users SET role = 0 WHERE role = 1"

    drop_table :reservations, if_exists: true
    drop_table :waitlist_entries, if_exists: true
    drop_table :external_checkins, if_exists: true
    drop_table :wellhub_bookings, if_exists: true
    drop_table :class_credits, if_exists: true
    drop_table :package_class_templates, if_exists: true
    drop_table :user_packages, if_exists: true
    drop_table :studio_classes, if_exists: true
    drop_table :class_templates, if_exists: true
    drop_table :packages, if_exists: true
    drop_table :categories, if_exists: true

    remove_column :users, :bio, :text, if_exists: true
    remove_column :users, :styles_taught, :text, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Eclipse-lite migration is one-way."
  end
end
