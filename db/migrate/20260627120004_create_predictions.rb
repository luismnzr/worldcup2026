class CreatePredictions < ActiveRecord::Migration[7.2]
  def change
    create_table :predictions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :match, null: false, foreign_key: true
      t.string  :advancing_pick           # equipo que el usuario cree que avanza
      t.integer :home_score               # bonus de marcador exacto (opcional)
      t.integer :away_score
      t.integer :points_awarded, default: 0, null: false

      t.timestamps
    end

    add_index :predictions, [ :user_id, :match_id ], unique: true
  end
end
