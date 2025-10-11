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

ActiveRecord::Schema[7.1].define(version: 2025_10_02_225053) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
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
    t.datetime "created_at", precision: nil, null: false
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
    t.string "checksum", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "kind", default: 0, null: false
    t.string "country_code", null: false
    t.string "city", null: false
    t.string "line1", null: false
    t.string "line2"
    t.string "postal_code"
    t.string "phone"
    t.string "contact_name"
    t.boolean "is_default", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "airpods", force: :cascade do |t|
    t.string "title"
    t.string "diagonal"
    t.string "model"
    t.string "version"
    t.string "series"
    t.datetime "production_period", precision: nil
    t.string "full_title"
    t.text "overview"
    t.string "avatar"
    t.string "images", default: [], array: true
    t.string "videos", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "airpods_users", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "airpod_id", null: false
    t.index ["airpod_id", "user_id"], name: "index_airpods_users_on_airpod_id_and_user_id"
    t.index ["user_id", "airpod_id"], name: "index_airpods_users_on_user_id_and_airpod_id"
  end

  create_table "answers", force: :cascade do |t|
    t.bigint "quiz_question_id", null: false
    t.bigint "user_id", null: false
    t.text "content"
    t.boolean "correct", default: false
    t.string "avatar", default: ""
    t.string "images", default: [], array: true
    t.string "videos", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_question_id"], name: "index_answers_on_quiz_question_id"
    t.index ["user_id"], name: "index_answers_on_user_id"
  end

  create_table "apple_watches", force: :cascade do |t|
    t.string "title"
    t.string "diagonal"
    t.string "model"
    t.string "version"
    t.string "series"
    t.datetime "production_period", precision: nil
    t.string "full_title"
    t.text "overview"
    t.string "avatar"
    t.string "images", default: [], array: true
    t.string "videos", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "apple_watches_users", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "apple_watch_id", null: false
    t.index ["apple_watch_id", "user_id"], name: "index_apple_watches_users_on_apple_watch_id_and_user_id"
    t.index ["user_id", "apple_watch_id"], name: "index_apple_watches_users_on_user_id_and_apple_watch_id"
  end

  create_table "articles", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.string "avatar", default: ""
    t.string "images", default: [], array: true
    t.string "videos", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_articles_on_user_id"
  end

  create_table "audit_logs", force: :cascade do |t|
    t.bigint "actor_id", null: false
    t.string "action", null: false
    t.string "subject_type", null: false
    t.bigint "subject_id", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_audit_logs_on_actor_id"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["subject_type", "subject_id"], name: "index_audit_logs_on_subject_type_and_subject_id"
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.decimal "unit_price", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "total", precision: 12, scale: 2, default: "0.0", null: false
    t.string "currency", default: "RUB", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id", "product_id"], name: "index_cart_items_on_cart_id_and_product_id", unique: true
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["product_id"], name: "index_cart_items_on_product_id"
  end

  create_table "carts", force: :cascade do |t|
    t.bigint "user_id"
    t.string "session_id"
    t.integer "items_count", default: 0, null: false
    t.decimal "total", precision: 12, scale: 2, default: "0.0", null: false
    t.string "currency", default: "RUB", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_carts_on_session_id", unique: true
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "heading", default: ""
    t.text "overview", default: ""
    t.boolean "display", default: true
    t.string "avatar", default: ""
    t.string "images", default: [], array: true
    t.string "videos", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "phone_id"
    t.string "slug"
    t.bigint "parent_id"
    t.string "device_type"
    t.bigint "device_id"
    t.bigint "generation_id"
    t.index ["device_type", "device_id", "heading"], name: "ux_categories_device_heading", unique: true
    t.index ["device_type", "device_id"], name: "idx_categories_device_poly"
    t.index ["generation_id", "heading"], name: "idx_categories_on_generation_heading_unique", unique: true, where: "(generation_id IS NOT NULL)"
    t.index ["generation_id"], name: "index_categories_on_generation_id"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["phone_id"], name: "index_categories_on_phone_id"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "categorizations", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.string "subject_type", null: false
    t.bigint "subject_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_categorizations_on_category_id"
    t.index ["subject_type", "subject_id"], name: "index_categorizations_on_subject_type_and_subject_id"
  end

  create_table "chapters", force: :cascade do |t|
    t.bigint "cource_id", null: false
    t.string "title"
    t.string "avatar", default: ""
    t.string "images", default: [], array: true
    t.string "videos", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cource_id"], name: "index_chapters_on_cource_id"
  end

  create_table "commissions", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "percent", precision: 6, scale: 3, default: "0.0", null: false
    t.integer "applies_to", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_commissions_on_active"
  end

  create_table "cources", force: :cascade do |t|
    t.bigint "university_id", null: false
    t.bigint "category_id", null: false
    t.bigint "generation_id", null: false
    t.bigint "model_id", null: false
    t.string "author"
    t.string "name"
    t.text "description"
    t.decimal "price"
    t.string "chapters", default: [], array: true
    t.string "avatar", default: ""
    t.string "images", default: [], array: true
    t.string "videos", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_cources_on_category_id"
    t.index ["generation_id"], name: "index_cources_on_generation_id"
    t.index ["model_id"], name: "index_cources_on_model_id"
    t.index ["university_id"], name: "index_cources_on_university_id"
  end

  create_table "defects", force: :cascade do |t|
    t.integer "generation_id"
    t.integer "phone_id"
    t.integer "repair_id"
    t.integer "mod_id"
    t.string "title"
    t.string "description"
    t.string "avatar"
    t.string "modules", default: [], array: true
    t.string "images", default: [], array: true
    t.string "videos", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "repairable_type"
    t.bigint "repairable_id"
    t.index ["repairable_type", "repairable_id"], name: "idx_defects_repairable_poly"
    t.index ["repairable_type", "repairable_id"], name: "index_defects_on_repairable"
  end

  create_table "defects_mods", id: false, force: :cascade do |t|
    t.bigint "defect_id", null: false
    t.bigint "mod_id", null: false
    t.index ["defect_id", "mod_id"], name: "index_defects_mods_on_defect_id_and_mod_id"
    t.index ["defect_id", "mod_id"], name: "ux_defects_mods_defect_id_mod_id", unique: true
    t.index ["mod_id", "defect_id"], name: "index_defects_mods_on_mod_id_and_defect_id"
  end

  create_table "defects_phones", id: false, force: :cascade do |t|
    t.bigint "phone_id", null: false
    t.bigint "defect_id", null: false
    t.index ["defect_id", "phone_id"], name: "index_defects_phones_on_defect_id_and_phone_id"
    t.index ["defect_id", "phone_id"], name: "ux_defects_phones_defect_id_phone_id", unique: true
    t.index ["phone_id", "defect_id"], name: "index_defects_phones_on_phone_id_and_defect_id"
  end

  create_table "defects_repairs", id: false, force: :cascade do |t|
    t.bigint "defect_id", null: false
    t.bigint "repair_id", null: false
    t.index ["defect_id", "repair_id"], name: "index_defects_repairs_on_defect_id_and_repair_id"
    t.index ["defect_id", "repair_id"], name: "ux_defects_repairs_defect_id_repair_id", unique: true
    t.index ["repair_id", "defect_id"], name: "index_defects_repairs_on_repair_id_and_defect_id"
  end

  create_table "generations", force: :cascade do |t|
    t.string "title"
    t.string "production_period"
    t.string "features"
    t.string "vulnerability"
    t.string "avatar"
    t.string "images", default: [], array: true
    t.string "videos", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "family"
    t.date "released_on"
    t.date "discontinued_on"
    t.text "aliases", default: [], array: true
    t.text "storage_options", default: [], array: true
    t.text "color_options", default: [], array: true
    t.index ["aliases"], name: "index_generations_on_aliases_gin", using: :gin
    t.index ["family", "title"], name: "idx_generations_family_title", unique: true
    t.index ["family"], name: "index_generations_on_family"
    t.index ["title"], name: "idx_generations_title_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["title"], name: "index_generations_on_title", unique: true
  end

  create_table "imacs", force: :cascade do |t|
    t.string "title"
    t.string "diagonal"
    t.string "model"
    t.string "version"
    t.string "series"
    t.datetime "production_period", precision: nil
    t.string "full_title"
    t.text "overview"
    t.string "avatar"
    t.string "images", default: [], array: true
    t.string "videos", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "imacs_users", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "imac_id", null: false
    t.index ["imac_id", "user_id"], name: "index_imacs_users_on_imac_id_and_user_id"
    t.index ["user_id", "imac_id"], name: "index_imacs_users_on_user_id_and_imac_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "repair_job_id", null: false
    t.integer "amount_cents", null: false
    t.string "currency", default: "RUB", null: false
    t.integer "status", default: 0, null: false
    t.date "due_on"
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["repair_job_id"], name: "index_invoices_on_repair_job_id"
    t.index ["status"], name: "index_invoices_on_status"
  end

  create_table "ipads", force: :cascade do |t|
    t.string "title"
    t.string "diagonal"
    t.string "model"
    t.string "version"
    t.string "series"
    t.datetime "production_period", precision: nil
    t.string "full_title"
    t.text "overview"
    t.string "avatar"
    t.string "images", default: [], array: true
    t.string "videos", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ipads_users", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "ipad_id", null: false
    t.index ["ipad_id", "user_id"], name: "index_ipads_users_on_ipad_id_and_user_id"
    t.index ["user_id", "ipad_id"], name: "index_ipads_users_on_user_id_and_ipad_id"
  end

  create_table "job_events", force: :cascade do |t|
    t.bigint "repair_job_id", null: false
    t.integer "kind", default: 0, null: false
    t.jsonb "payload", default: {}, null: false
    t.datetime "occurred_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["occurred_at"], name: "index_job_events_on_occurred_at"
    t.index ["repair_job_id"], name: "index_job_events_on_repair_job_id"
  end

  create_table "makbooks", force: :cascade do |t|
    t.string "title"
    t.string "diagonal"
    t.string "model"
    t.string "version"
    t.string "series"
    t.datetime "production_period", precision: nil
    t.string "full_title"
    t.text "overview"
    t.string "avatar"
    t.string "images", default: [], array: true
    t.string "videos", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "makbooks_users", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "makbook_id", null: false
    t.index ["makbook_id", "user_id"], name: "index_makbooks_users_on_makbook_id_and_user_id"
    t.index ["user_id", "makbook_id"], name: "index_makbooks_users_on_user_id_and_makbook_id"
  end

  create_table "master_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "headline"
    t.text "skills"
    t.integer "experience_years"
    t.integer "hourly_rate_cents", default: 0, null: false
    t.decimal "rating_avg", precision: 4, scale: 2, default: "0.0", null: false
    t.integer "reviews_count", default: 0, null: false
    t.integer "certifications_count", default: 0, null: false
    t.integer "portfolio_items_count", default: 0, null: false
    t.datetime "verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_master_profiles_on_user_id", unique: true
  end

  create_table "models", force: :cascade do |t|
    t.integer "generation_id"
    t.integer "phone_id"
    t.string "title"
    t.string "avatar"
    t.string "images", default: [], array: true
    t.string "videos", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((title)::text)", name: "index_models_on_lower_title"
    t.index ["title"], name: "idx_models_title_trgm", opclass: :gin_trgm_ops, using: :gin
  end

  create_table "mods", force: :cascade do |t|
    t.integer "generation_id"
    t.integer "phone_id"
    t.integer "model_id"
    t.integer "defect_id"
    t.integer "repair_id"
    t.string "name"
    t.string "avatar"
    t.string "manufacturers", default: [], array: true
    t.string "images", default: [], array: true
    t.string "videos", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "repairable_type"
    t.bigint "repairable_id"
    t.index ["repairable_type", "repairable_id"], name: "idx_mods_repairable_poly"
    t.index ["repairable_type", "repairable_id"], name: "index_mods_on_repairable"
  end

  create_table "mods_repairs", id: false, force: :cascade do |t|
    t.bigint "repair_id", null: false
    t.bigint "mod_id", null: false
    t.index ["mod_id", "repair_id"], name: "index_mods_repairs_on_mod_id_and_repair_id"
    t.index ["mod_id", "repair_id"], name: "ux_mods_repairs_mod_id_repair_id", unique: true
    t.index ["repair_id", "mod_id"], name: "index_mods_repairs_on_repair_id_and_mod_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "notifiable_type"
    t.bigint "notifiable_id"
    t.integer "channel", default: 0, null: false
    t.string "kind"
    t.jsonb "payload", default: {}, null: false
    t.datetime "read_at"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id"
    t.index ["read_at"], name: "index_notifications_on_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "order_id", null: false
    t.integer "quantity"
    t.decimal "total"
    t.decimal "unit_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "currency", default: "RUB", null: false
    t.string "title_snapshot"
    t.jsonb "meta", default: {}, null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.decimal "subtotal"
    t.decimal "total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "seller_id"
    t.string "number"
    t.integer "state", default: 0, null: false
    t.decimal "delivery", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "fee", precision: 12, scale: 2, default: "0.0", null: false
    t.string "currency", default: "RUB", null: false
    t.integer "payment_method"
    t.bigint "shipping_address_id"
    t.bigint "billing_address_id"
    t.datetime "paid_at"
    t.datetime "canceled_at"
    t.string "reason"
    t.jsonb "metadata", default: {}, null: false
    t.index ["billing_address_id"], name: "index_orders_on_billing_address_id"
    t.index ["number"], name: "index_orders_on_number", unique: true
    t.index ["paid_at"], name: "index_orders_on_paid_at"
    t.index ["seller_id"], name: "index_orders_on_seller_id"
    t.index ["shipping_address_id"], name: "index_orders_on_shipping_address_id"
    t.index ["state"], name: "index_orders_on_state"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "owned_gadgets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "avatar"
    t.string "images", default: [], array: true
    t.string "videos", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_owned_gadgets_on_user_id"
  end

  create_table "owned_gadgets_phones", id: false, force: :cascade do |t|
    t.bigint "owned_gadget_id", null: false
    t.bigint "phone_id", null: false
    t.index ["owned_gadget_id", "phone_id"], name: "index_owned_gadgets_phones_on_owned_gadget_id_and_phone_id"
    t.index ["phone_id", "owned_gadget_id"], name: "index_owned_gadgets_phones_on_phone_id_and_owned_gadget_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.integer "provider", default: 0, null: false
    t.string "provider_payment_id"
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.string "currency", default: "RUB", null: false
    t.integer "status", default: 0, null: false
    t.string "error_code"
    t.jsonb "payload", default: {}, null: false
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_payments_on_order_id"
    t.index ["provider", "provider_payment_id"], name: "index_payments_on_provider_and_provider_payment_id", unique: true
    t.index ["status"], name: "index_payments_on_status"
  end

  create_table "payouts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "amount_cents", null: false
    t.string "currency", default: "RUB", null: false
    t.integer "state", default: 0, null: false
    t.string "provider"
    t.jsonb "payload", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["state"], name: "index_payouts_on_state"
    t.index ["user_id"], name: "index_payouts_on_user_id"
  end

  create_table "phones", force: :cascade do |t|
    t.string "model_title"
    t.string "model_overview"
    t.string "avatar"
    t.string "images", default: [], array: true
    t.string "videos", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "generation_id", null: false
    t.index "lower((model_title)::text)", name: "index_phones_on_lower_model_title"
    t.index ["generation_id"], name: "index_phones_on_generation_id"
    t.index ["model_title"], name: "idx_phones_model_title_trgm", opclass: :gin_trgm_ops, using: :gin
  end

  create_table "phones_repairs", id: false, force: :cascade do |t|
    t.bigint "repair_id", null: false
    t.bigint "phone_id", null: false
    t.index ["phone_id", "repair_id"], name: "index_phones_repairs_on_phone_id_and_repair_id"
    t.index ["phone_id", "repair_id"], name: "ux_phones_repairs_phone_id_repair_id", unique: true
    t.index ["repair_id", "phone_id"], name: "index_phones_repairs_on_repair_id_and_phone_id"
  end

  create_table "phones_users", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "phone_id", null: false
    t.index ["phone_id", "user_id"], name: "index_phones_users_on_phone_id_and_user_id"
    t.index ["user_id", "phone_id"], name: "index_phones_users_on_user_id_and_phone_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.integer "views", default: 0
    t.string "avatar", default: ""
    t.string "images", default: [], array: true
    t.string "videos", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "product_defects", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "defect_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["defect_id"], name: "index_product_defects_on_defect_id"
    t.index ["product_id", "defect_id"], name: "index_product_defects_on_product_id_and_defect_id", unique: true
    t.index ["product_id", "defect_id"], name: "ux_product_defects_product_id_defect_id", unique: true
    t.index ["product_id"], name: "idx_product_defects_product_id"
    t.index ["product_id"], name: "index_product_defects_on_product_id"
  end

  create_table "product_mods", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "mod_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mod_id"], name: "index_product_mods_on_mod_id"
    t.index ["product_id", "mod_id"], name: "index_product_mods_on_product_id_and_mod_id", unique: true
    t.index ["product_id", "mod_id"], name: "ux_product_mods_product_id_mod_id", unique: true
    t.index ["product_id"], name: "idx_product_mods_product_id"
    t.index ["product_id"], name: "index_product_mods_on_product_id"
  end

  create_table "product_repairs", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "repair_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "repair_id"], name: "index_product_repairs_on_product_id_and_repair_id", unique: true
    t.index ["product_id", "repair_id"], name: "ux_product_repairs_product_id_repair_id", unique: true
    t.index ["product_id"], name: "idx_product_repairs_product_id"
    t.index ["product_id"], name: "index_product_repairs_on_product_id"
    t.index ["repair_id"], name: "index_product_repairs_on_repair_id"
  end

  create_table "product_spare_parts", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "spare_part_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "spare_part_id"], name: "index_product_spare_parts_on_product_id_and_spare_part_id", unique: true
    t.index ["product_id", "spare_part_id"], name: "ux_product_spare_parts_product_id_spare_part_id", unique: true
    t.index ["product_id"], name: "idx_product_spare_parts_product_id"
    t.index ["product_id"], name: "index_product_spare_parts_on_product_id"
    t.index ["spare_part_id"], name: "index_product_spare_parts_on_spare_part_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", default: ""
    t.text "description", default: ""
    t.decimal "price", default: "0.0"
    t.boolean "is_best_offer", default: false
    t.string "avatar", default: ""
    t.string "images", default: [], array: true
    t.string "videos", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "category_id"
    t.integer "condition", default: 1, null: false
    t.integer "state", default: 0, null: false
    t.integer "stock", default: 1, null: false
    t.string "currency", default: "RUB", null: false
    t.jsonb "location_json", default: {}, null: false
    t.boolean "featured", default: false, null: false
    t.integer "violations_count", default: 0, null: false
    t.bigint "phone_id"
    t.bigint "generation_id"
    t.string "storage"
    t.string "color"
    t.bigint "model_id"
    t.bigint "seller_id"
    t.bigint "sku_id"
    t.index "lower((name)::text)", name: "index_products_on_lower_name"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["condition"], name: "index_products_on_condition"
    t.index ["generation_id"], name: "idx_products_generation_for_non_draft", where: "(state <> 0)"
    t.index ["generation_id"], name: "index_products_on_generation_id"
    t.index ["model_id"], name: "index_products_on_model_id"
    t.index ["phone_id"], name: "index_products_on_phone_id"
    t.index ["price"], name: "index_products_on_price"
    t.index ["seller_id", "sku_id"], name: "idx_products_unique_published_sku_per_seller", unique: true, where: "(state <> 0)"
    t.index ["seller_id", "sku_id"], name: "ux_products_seller_id_sku_id_not_draft", unique: true, where: "((sku_id IS NOT NULL) AND (state <> 0))"
    t.index ["seller_id"], name: "index_products_on_seller_id"
    t.index ["sku_id"], name: "index_products_on_sku_id"
    t.index ["state", "price"], name: "idx_products_state_price", where: "(price IS NOT NULL)"
    t.index ["state"], name: "index_products_on_state"
    t.check_constraint "condition = ANY (ARRAY[0, 1, 2, 3])", name: "products_condition_enum"
    t.check_constraint "state = 0 OR price IS NOT NULL AND price > 0::numeric", name: "products_price_positive_for_non_draft"
    t.check_constraint "state = 0 OR sku_id IS NOT NULL", name: "products_sku_required_for_non_draft"
    t.check_constraint "state = ANY (ARRAY[0, 1, 2, 3, 4])", name: "products_state_enum"
  end

  create_table "quiz_questions", force: :cascade do |t|
    t.bigint "quiz_id", null: false
    t.text "content"
    t.string "avatar", default: ""
    t.string "images", default: [], array: true
    t.string "videos", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id"], name: "index_quiz_questions_on_quiz_id"
  end

  create_table "quizzes", force: :cascade do |t|
    t.bigint "cource_id", null: false
    t.bigint "chapter_id", null: false
    t.string "name"
    t.text "description"
    t.string "avatar", default: ""
    t.string "images", default: [], array: true
    t.string "videos", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "passing_score", default: 70
    t.integer "num_questions_to_show", default: 10
    t.index ["chapter_id"], name: "index_quizzes_on_chapter_id"
    t.index ["cource_id"], name: "index_quizzes_on_cource_id"
  end

  create_table "repair_bids", force: :cascade do |t|
    t.bigint "repair_request_id", null: false
    t.bigint "master_id", null: false
    t.integer "price_cents"
    t.integer "estimate_days"
    t.text "message"
    t.integer "state", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["master_id"], name: "index_repair_bids_on_master_id"
    t.index ["repair_request_id"], name: "index_repair_bids_on_repair_request_id"
    t.index ["state"], name: "index_repair_bids_on_state"
  end

  create_table "repair_jobs", force: :cascade do |t|
    t.bigint "repair_request_id", null: false
    t.bigint "master_id", null: false
    t.integer "state", default: 0, null: false
    t.integer "progress_pct", default: 0, null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["master_id"], name: "index_repair_jobs_on_master_id"
    t.index ["repair_request_id"], name: "index_repair_jobs_on_repair_request_id"
    t.index ["state"], name: "index_repair_jobs_on_state"
  end

  create_table "repair_requests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.bigint "phone_id"
    t.bigint "generation_id"
    t.integer "kind", default: 0, null: false
    t.string "title", null: false
    t.text "description"
    t.integer "budget_cents"
    t.string "currency", default: "RUB", null: false
    t.integer "urgency", default: 1, null: false
    t.integer "state", default: 0, null: false
    t.jsonb "location_json", default: {}, null: false
    t.integer "attachments_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_repair_requests_on_category_id"
    t.index ["generation_id"], name: "index_repair_requests_on_generation_id"
    t.index ["kind"], name: "index_repair_requests_on_kind"
    t.index ["phone_id"], name: "index_repair_requests_on_phone_id"
    t.index ["state"], name: "index_repair_requests_on_state"
    t.index ["user_id"], name: "index_repair_requests_on_user_id"
  end

  create_table "repairs", force: :cascade do |t|
    t.integer "generation_id"
    t.integer "phone_id"
    t.integer "defect_id"
    t.integer "mod_id"
    t.string "title"
    t.string "description"
    t.string "overview"
    t.string "avatar"
    t.string "spare_parts", default: [], array: true
    t.string "images", default: [], array: true
    t.string "videos", default: [], array: true
    t.string "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "repairable_type"
    t.bigint "repairable_id"
    t.index ["repairable_type", "repairable_id"], name: "idx_repairs_repairable_poly"
    t.index ["repairable_type", "repairable_id"], name: "index_repairs_on_repairable"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "seller_id", null: false
    t.bigint "product_id", null: false
    t.integer "rating", null: false
    t.text "pros"
    t.text "cons"
    t.text "body"
    t.integer "state", default: 0, null: false
    t.datetime "moderated_at"
    t.integer "violations_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_reviews_on_product_id"
    t.index ["seller_id"], name: "index_reviews_on_seller_id"
    t.index ["state"], name: "index_reviews_on_state"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "shipments", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "tracking_number"
    t.string "carrier"
    t.integer "status", default: 0, null: false
    t.jsonb "payload", default: {}, null: false
    t.datetime "shipped_at"
    t.datetime "delivered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_shipments_on_order_id"
    t.index ["tracking_number"], name: "index_shipments_on_tracking_number"
  end

  create_table "skus", force: :cascade do |t|
    t.bigint "generation_id", null: false
    t.bigint "phone_id"
    t.string "storage"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "generation_id, COALESCE(lower((storage)::text), ''::text), COALESCE(lower((color)::text), ''::text)", name: "ux_skus_generation_storage_color", unique: true
    t.index ["generation_id", "storage", "color"], name: "idx_skus_generation_storage_color"
    t.index ["generation_id"], name: "index_skus_on_generation_id"
    t.index ["phone_id"], name: "index_skus_on_phone_id"
  end

  create_table "spare_parts", force: :cascade do |t|
    t.integer "generation_id"
    t.integer "phone_id"
    t.integer "mod_id"
    t.string "name"
    t.string "manufacturer"
    t.string "avatar"
    t.string "images", default: [], array: true
    t.string "videos", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "repairable_type"
    t.bigint "repairable_id"
    t.index ["repairable_type", "repairable_id"], name: "idx_spare_parts_repairable_poly"
    t.index ["repairable_type", "repairable_id"], name: "index_spare_parts_on_repairable"
  end

  create_table "subscription_plans", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "price_cents", default: 0, null: false
    t.integer "interval", default: 0, null: false
    t.jsonb "features", default: {}, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_subscription_plans_on_active"
    t.index ["slug"], name: "index_subscription_plans_on_slug", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "subscription_plan_id", null: false
    t.integer "state", default: 0, null: false
    t.datetime "current_period_end", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["state"], name: "index_subscriptions_on_state"
    t.index ["subscription_plan_id"], name: "index_subscriptions_on_subscription_plan_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "universities", force: :cascade do |t|
    t.string "title"
    t.string "avatar", default: ""
    t.string "images", default: [], array: true
    t.string "videos", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "username", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "avatar"
    t.boolean "admin", default: false
    t.boolean "author", default: true
    t.boolean "repairman", default: false
    t.boolean "teacher", default: false
    t.boolean "student", default: false
    t.boolean "customer", default: true
    t.string "first_name"
    t.string "last_name"
    t.datetime "borned", precision: nil
    t.datetime "birthday", precision: nil
    t.text "images", default: [], array: true
    t.text "videos", default: [], array: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "violation_reports", force: :cascade do |t|
    t.bigint "reporter_id", null: false
    t.string "reportable_type", null: false
    t.bigint "reportable_id", null: false
    t.integer "reason", default: 0, null: false
    t.text "details"
    t.integer "state", default: 0, null: false
    t.bigint "moderator_id"
    t.text "resolution"
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["moderator_id"], name: "index_violation_reports_on_moderator_id"
    t.index ["reportable_type", "reportable_id"], name: "index_violation_reports_on_reportable_type_and_reportable_id"
    t.index ["reporter_id"], name: "index_violation_reports_on_reporter_id"
    t.index ["state"], name: "index_violation_reports_on_state"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "users"
  add_foreign_key "answers", "quiz_questions"
  add_foreign_key "answers", "users"
  add_foreign_key "audit_logs", "users", column: "actor_id"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "products"
  add_foreign_key "carts", "users"
  add_foreign_key "categories", "generations"
  add_foreign_key "categories", "phones"
  add_foreign_key "categorizations", "categories"
  add_foreign_key "chapters", "cources"
  add_foreign_key "cources", "categories"
  add_foreign_key "cources", "generations"
  add_foreign_key "cources", "models"
  add_foreign_key "cources", "universities"
  add_foreign_key "defects_mods", "defects", name: "fk_dm_defect", on_delete: :cascade
  add_foreign_key "defects_mods", "mods", name: "fk_dm_mod", on_delete: :cascade
  add_foreign_key "defects_repairs", "defects", name: "fk_dr_defect", on_delete: :cascade
  add_foreign_key "defects_repairs", "repairs", name: "fk_dr_repair", on_delete: :cascade
  add_foreign_key "invoices", "repair_jobs"
  add_foreign_key "job_events", "repair_jobs"
  add_foreign_key "master_profiles", "users"
  add_foreign_key "mods_repairs", "mods", name: "fk_mr_mod", on_delete: :cascade
  add_foreign_key "mods_repairs", "repairs", name: "fk_mr_repair", on_delete: :cascade
  add_foreign_key "notifications", "users"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "addresses", column: "billing_address_id"
  add_foreign_key "orders", "addresses", column: "shipping_address_id"
  add_foreign_key "orders", "users"
  add_foreign_key "orders", "users", column: "seller_id"
  add_foreign_key "owned_gadgets", "users"
  add_foreign_key "payments", "orders"
  add_foreign_key "payouts", "users"
  add_foreign_key "phones", "generations"
  add_foreign_key "phones_repairs", "phones", name: "fk_pr_phone", on_delete: :cascade
  add_foreign_key "phones_repairs", "repairs", name: "fk_pr_repair", on_delete: :cascade
  add_foreign_key "posts", "users"
  add_foreign_key "product_defects", "defects"
  add_foreign_key "product_defects", "defects", name: "fk_prddef_defect", on_delete: :cascade
  add_foreign_key "product_defects", "products"
  add_foreign_key "product_defects", "products", name: "fk_prddef_product", on_delete: :cascade
  add_foreign_key "product_mods", "mods"
  add_foreign_key "product_mods", "mods", name: "fk_prdmod_mod", on_delete: :cascade
  add_foreign_key "product_mods", "products"
  add_foreign_key "product_mods", "products", name: "fk_prdmod_product", on_delete: :cascade
  add_foreign_key "product_repairs", "products"
  add_foreign_key "product_repairs", "products", name: "fk_prdrep_product", on_delete: :cascade
  add_foreign_key "product_repairs", "repairs"
  add_foreign_key "product_repairs", "repairs", name: "fk_prdrep_repair", on_delete: :cascade
  add_foreign_key "product_spare_parts", "products"
  add_foreign_key "product_spare_parts", "products", name: "fk_prdsp_product", on_delete: :cascade
  add_foreign_key "product_spare_parts", "spare_parts"
  add_foreign_key "product_spare_parts", "spare_parts", name: "fk_prdsp_spare", on_delete: :cascade
  add_foreign_key "products", "categories"
  add_foreign_key "products", "generations"
  add_foreign_key "products", "models"
  add_foreign_key "products", "phones"
  add_foreign_key "products", "skus", on_delete: :nullify
  add_foreign_key "products", "users", column: "seller_id"
  add_foreign_key "quiz_questions", "quizzes"
  add_foreign_key "quizzes", "chapters"
  add_foreign_key "quizzes", "cources"
  add_foreign_key "repair_bids", "repair_requests"
  add_foreign_key "repair_bids", "users", column: "master_id"
  add_foreign_key "repair_jobs", "repair_requests"
  add_foreign_key "repair_jobs", "users", column: "master_id"
  add_foreign_key "repair_requests", "categories"
  add_foreign_key "repair_requests", "generations"
  add_foreign_key "repair_requests", "phones"
  add_foreign_key "repair_requests", "users"
  add_foreign_key "reviews", "products"
  add_foreign_key "reviews", "users"
  add_foreign_key "reviews", "users", column: "seller_id"
  add_foreign_key "shipments", "orders"
  add_foreign_key "skus", "generations"
  add_foreign_key "skus", "phones"
  add_foreign_key "subscriptions", "subscription_plans"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "violation_reports", "users", column: "moderator_id"
  add_foreign_key "violation_reports", "users", column: "reporter_id"
end
