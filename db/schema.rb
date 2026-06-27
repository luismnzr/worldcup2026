# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_06_27_120004) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_notifications", force: :cascade do |t|
    t.string "title", null: false
    t.string "body"
    t.string "category", null: false
    t.string "action_url"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_admin_notifications_on_category"
    t.index ["created_at"], name: "index_admin_notifications_on_created_at"
    t.index ["read_at"], name: "index_admin_notifications_on_read_at"
  end

  create_table "entries", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "tournament_id", null: false
    t.integer "status", default: 0, null: false
    t.decimal "amount", precision: 10, scale: 2
    t.string "stripe_checkout_session_id"
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stripe_checkout_session_id"], name: "index_entries_on_stripe_checkout_session_id", unique: true
    t.index ["tournament_id"], name: "index_entries_on_tournament_id"
    t.index ["user_id", "tournament_id"], name: "index_entries_on_user_id_and_tournament_id", unique: true
    t.index ["user_id"], name: "index_entries_on_user_id"
  end

  create_table "event_registrations", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "user_id", null: false
    t.string "status", default: "confirmed", null: false
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_registrations_on_event_id"
    t.index ["user_id", "event_id"], name: "index_event_registrations_on_user_and_event_active", unique: true, where: "((status)::text <> 'cancelled'::text)"
    t.index ["user_id"], name: "index_event_registrations_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.date "date", null: false
    t.time "start_time"
    t.time "end_time"
    t.string "location"
    t.integer "capacity"
    t.integer "spots_remaining"
    t.boolean "published", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "price", precision: 10, scale: 2
    t.date "end_date"
    t.boolean "in_person_payment_only", default: false, null: false
    t.index ["date"], name: "index_events_on_date"
    t.index ["published"], name: "index_events_on_published"
  end

  create_table "matches", force: :cascade do |t|
    t.integer "number", null: false
    t.string "stage", null: false
    t.string "home_label"
    t.string "away_label"
    t.integer "home_source_number"
    t.integer "away_source_number"
    t.string "home_source_result"
    t.string "away_source_result"
    t.string "home_team"
    t.string "away_team"
    t.integer "home_score"
    t.integer "away_score"
    t.string "advancing_team"
    t.datetime "kickoff_at"
    t.string "venue"
    t.string "status", default: "scheduled", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kickoff_at"], name: "index_matches_on_kickoff_at"
    t.index ["number"], name: "index_matches_on_number", unique: true
    t.index ["stage"], name: "index_matches_on_stage"
  end

  create_table "member_posts", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.text "excerpt"
    t.text "body"
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["published_at"], name: "index_member_posts_on_published_at"
    t.index ["slug"], name: "index_member_posts_on_slug", unique: true
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id"
    t.decimal "total", precision: 10, scale: 2, null: false
    t.string "status", default: "pending", null: false
    t.text "notes"
    t.string "stripe_payment_intent_id"
    t.string "payment_method", default: "cash", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "phone"
    t.string "shipping_name"
    t.string "shipping_address_line1"
    t.string "shipping_address_line2"
    t.string "shipping_city"
    t.string "shipping_state"
    t.string "shipping_postal_code"
    t.string "shipping_country"
    t.string "shipping_status", default: "unfulfilled", null: false
    t.string "tracking_number"
    t.decimal "subtotal", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "shipping_cost", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "discount_total", precision: 10, scale: 2, default: "0.0", null: false
    t.bigint "promotion_code_id"
    t.string "stripe_checkout_session_id"
    t.index ["promotion_code_id"], name: "index_orders_on_promotion_code_id"
    t.index ["shipping_status"], name: "index_orders_on_shipping_status"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["stripe_checkout_session_id"], name: "index_orders_on_stripe_checkout_session_id", unique: true, where: "(stripe_checkout_session_id IS NOT NULL)"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "pages", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.boolean "published", default: false, null: false
    t.integer "sort_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["published"], name: "index_pages_on_published"
    t.index ["slug"], name: "index_pages_on_slug", unique: true
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "stripe_payment_intent_id"
    t.string "stripe_checkout_session_id"
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "currency", default: "mxn", null: false
    t.string "status", default: "pending", null: false
    t.string "description"
    t.string "payable_type"
    t.bigint "payable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "payment_method", default: "stripe"
    t.index ["payable_type", "payable_id"], name: "index_payments_on_payable_type_and_payable_id"
    t.index ["stripe_checkout_session_id"], name: "index_payments_on_stripe_checkout_session_id", unique: true
    t.index ["stripe_payment_intent_id"], name: "index_payments_on_stripe_payment_intent_id", unique: true
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "predictions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "match_id", null: false
    t.string "advancing_pick"
    t.integer "home_score"
    t.integer "away_score"
    t.integer "points_awarded", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_predictions_on_match_id"
    t.index ["user_id", "match_id"], name: "index_predictions_on_user_id_and_match_id", unique: true
    t.index ["user_id"], name: "index_predictions_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "stock_quantity", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "sku"
    t.string "kind", default: "physical", null: false
    t.boolean "requires_shipping", default: true, null: false
    t.decimal "shipping_cost", precision: 10, scale: 2, default: "0.0", null: false
    t.index ["active"], name: "index_products_on_active"
    t.index ["kind"], name: "index_products_on_kind"
    t.index ["sku"], name: "index_products_on_sku", unique: true, where: "(sku IS NOT NULL)"
    t.index ["slug"], name: "index_products_on_slug", unique: true
  end

  create_table "promotion_codes", force: :cascade do |t|
    t.string "code", null: false
    t.string "discount_type", null: false
    t.decimal "discount_value", precision: 10, scale: 2, null: false
    t.integer "max_redemptions"
    t.integer "times_redeemed", default: 0, null: false
    t.datetime "expires_at"
    t.boolean "active", default: true, null: false
    t.string "stripe_coupon_id"
    t.string "stripe_promotion_code_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "applies_to", default: "all", null: false
    t.index ["active"], name: "index_promotion_codes_on_active"
    t.index ["applies_to"], name: "index_promotion_codes_on_applies_to"
    t.index ["code"], name: "index_promotion_codes_on_code", unique: true
  end

  create_table "stripe_webhook_events", force: :cascade do |t|
    t.string "stripe_event_id", null: false
    t.string "event_type", null: false
    t.datetime "processed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_type"], name: "index_stripe_webhook_events_on_event_type"
    t.index ["stripe_event_id"], name: "index_stripe_webhook_events_on_stripe_event_id", unique: true
  end

  create_table "studio_settings", force: :cascade do |t|
    t.string "key", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_studio_settings_on_key", unique: true
  end

  create_table "subscription_plans", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.string "interval", default: "monthly", null: false
    t.string "stripe_price_id"
    t.text "description"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "featured", default: false, null: false
    t.integer "sort_order", default: 0, null: false
    t.text "features"
    t.string "badge_label"
    t.index ["active"], name: "index_subscription_plans_on_active"
    t.index ["sort_order"], name: "index_subscription_plans_on_sort_order"
    t.index ["stripe_price_id"], name: "index_subscription_plans_on_stripe_price_id", unique: true
  end

  create_table "tournaments", force: :cascade do |t|
    t.string "name", default: "FIFA World Cup 2026", null: false
    t.decimal "entry_fee", precision: 10, scale: 2, default: "50.0", null: false
    t.string "currency", default: "MXN", null: false
    t.text "prize_description"
    t.integer "exact_score_bonus", default: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "subscription_plan_id", null: false
    t.string "stripe_subscription_id"
    t.string "stripe_customer_id"
    t.string "status", default: "active", null: false
    t.datetime "current_period_start"
    t.datetime "current_period_end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stripe_subscription_id"], name: "index_user_subscriptions_on_stripe_subscription_id", unique: true
    t.index ["subscription_plan_id"], name: "index_user_subscriptions_on_subscription_plan_id"
    t.index ["user_id", "status"], name: "index_user_subscriptions_on_user_id_and_status"
    t.index ["user_id"], name: "index_user_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.integer "role", default: 0, null: false
    t.string "phone"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_customer_id"
    t.text "notes"
    t.boolean "featured", default: false, null: false
    t.string "display_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["stripe_customer_id"], name: "index_users_on_stripe_customer_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "entries", "tournaments"
  add_foreign_key "entries", "users"
  add_foreign_key "event_registrations", "events"
  add_foreign_key "event_registrations", "users"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "promotion_codes"
  add_foreign_key "orders", "users"
  add_foreign_key "payments", "users"
  add_foreign_key "predictions", "matches"
  add_foreign_key "predictions", "users"
  add_foreign_key "user_subscriptions", "subscription_plans"
  add_foreign_key "user_subscriptions", "users"
end
