class CreatePromotionCodes < ActiveRecord::Migration[7.2]
  def change
    create_table :promotion_codes do |t|
      t.string :code, null: false
      t.string :discount_type, null: false
      t.decimal :discount_value, precision: 10, scale: 2, null: false
      t.integer :max_redemptions
      t.integer :times_redeemed, default: 0, null: false
      t.datetime :expires_at
      t.boolean :active, default: true, null: false
      t.string :stripe_coupon_id
      t.string :stripe_promotion_code_id
      t.timestamps
    end

    add_index :promotion_codes, :code, unique: true
    add_index :promotion_codes, :active
  end
end
