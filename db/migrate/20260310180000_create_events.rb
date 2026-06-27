class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.text :description
      t.date :date, null: false
      t.time :start_time
      t.time :end_time
      t.string :location
      t.integer :capacity
      t.integer :spots_remaining
      t.boolean :published, default: false, null: false

      t.timestamps
    end

    add_index :events, :date
    add_index :events, :published
  end
end
