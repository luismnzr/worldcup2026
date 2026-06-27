class ExpandShopSchema < ActiveRecord::Migration[7.2]
  def change
    change_table :products do |t|
      t.string :slug
      t.string :sku
      t.string :kind, default: "physical", null: false
      t.boolean :requires_shipping, default: true, null: false
      t.decimal :shipping_cost, precision: 10, scale: 2, default: 0, null: false
    end

    add_index :products, :slug, unique: true
    add_index :products, :sku, unique: true, where: "sku IS NOT NULL"
    add_index :products, :kind

    change_table :orders do |t|
      t.string  :email
      t.string  :phone
      t.string  :shipping_name
      t.string  :shipping_address_line1
      t.string  :shipping_address_line2
      t.string  :shipping_city
      t.string  :shipping_state
      t.string  :shipping_postal_code
      t.string  :shipping_country
      t.string  :shipping_status, default: "unfulfilled", null: false
      t.string  :tracking_number
      t.decimal :subtotal, precision: 10, scale: 2, default: 0, null: false
      t.decimal :shipping_cost, precision: 10, scale: 2, default: 0, null: false
      t.decimal :discount_total, precision: 10, scale: 2, default: 0, null: false
      t.references :promotion_code, foreign_key: true
      t.string :stripe_checkout_session_id
    end

    add_index :orders, :shipping_status
    add_index :orders, :stripe_checkout_session_id, unique: true, where: "stripe_checkout_session_id IS NOT NULL"

    change_table :promotion_codes do |t|
      t.string :applies_to, default: "all", null: false
    end

    add_index :promotion_codes, :applies_to
  end
end
