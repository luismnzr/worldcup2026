class CreateEventRegistrations < ActiveRecord::Migration[7.2]
  def change
    create_table :event_registrations do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, default: "confirmed", null: false
      t.datetime :cancelled_at

      t.timestamps
    end

    add_index :event_registrations, [ :user_id, :event_id ], unique: true, where: "status != 'cancelled'", name: "index_event_registrations_on_user_and_event_active"
  end
end
