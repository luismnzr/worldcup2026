class CreateMatches < ActiveRecord::Migration[7.2]
  def change
    create_table :matches do |t|
      t.integer  :number,        null: false   # número oficial FIFA (73–104)
      t.string   :stage,         null: false   # r32, r16, qf, sf, third, final
      t.string   :home_label                   # etiqueta display antes de saber equipos ("2A", "Ganador P74")
      t.string   :away_label
      t.integer  :home_source_number           # partido del que sale el equipo local (nil en R32)
      t.integer  :away_source_number
      t.string   :home_source_result           # "winner" / "loser"
      t.string   :away_source_result
      t.string   :home_team                    # se llena cuando se conoce
      t.string   :away_team
      t.integer  :home_score
      t.integer  :away_score
      t.string   :advancing_team               # quién avanza (resuelve penales)
      t.datetime :kickoff_at
      t.string   :venue
      t.string   :status,        default: "scheduled", null: false  # scheduled, live, finished

      t.timestamps
    end

    add_index :matches, :number, unique: true
    add_index :matches, :stage
    add_index :matches, :kickoff_at
  end
end
