class CreateEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :entries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :tournament, null: false, foreign_key: true
      t.integer  :status, default: 0, null: false # pending / paid
      t.decimal  :amount, precision: 10, scale: 2
      t.string   :stripe_checkout_session_id
      t.datetime :paid_at

      t.timestamps
    end

    add_index :entries, [ :user_id, :tournament_id ], unique: true
    add_index :entries, :stripe_checkout_session_id, unique: true
  end
end
