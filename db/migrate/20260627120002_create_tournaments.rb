class CreateTournaments < ActiveRecord::Migration[7.2]
  def change
    create_table :tournaments do |t|
      t.string  :name, null: false, default: "FIFA World Cup 2026"
      t.decimal :entry_fee, precision: 10, scale: 2, default: "50.0", null: false
      t.string  :currency, null: false, default: "MXN"
      t.text    :prize_description
      t.integer :exact_score_bonus, default: 2, null: false # puntos extra por marcador exacto

      t.timestamps
    end
  end
end
