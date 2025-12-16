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

ActiveRecord::Schema[8.1].define(version: 2025_09_11_000048) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "address", null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "ens_name"
    t.integer "kind", null: false
    t.string "sns"
    t.datetime "updated_at", null: false
  end

  create_table "dollar_yen_transactions", force: :cascade do |t|
    t.integer "address_id"
    t.decimal "balance_en", null: false
    t.decimal "balance_quantity", null: false
    t.decimal "balance_rate", null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.datetime "deleted_at"
    t.decimal "deposit_en"
    t.decimal "deposit_quantity"
    t.decimal "deposit_rate"
    t.decimal "exchange_difference"
    t.decimal "exchange_en"
    t.integer "transaction_type_id"
    t.datetime "updated_at", null: false
    t.decimal "withdrawal_en"
    t.decimal "withdrawal_quantity"
    t.decimal "withdrawal_rate"
    t.index ["address_id"], name: "index_dollar_yen_transactions_on_address_id"
    t.index ["transaction_type_id", "date"], name: "index_dollar_yen_transactions_on_transaction_type_id_and_date", unique: true
    t.index ["transaction_type_id"], name: "index_dollar_yen_transactions_on_transaction_type_id"
  end

  create_table "dollar_yens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.decimal "dollar_yen_nakane", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_dollar_yens_on_date", unique: true
  end

  create_table "import_file_errors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "error_json"
    t.integer "import_file_id"
    t.datetime "updated_at", null: false
    t.index ["import_file_id"], name: "index_import_file_errors_on_import_file_id"
  end

  create_table "import_files", force: :cascade do |t|
    t.integer "address_id", null: false
    t.datetime "created_at", null: false
    t.integer "job_id", null: false
    t.integer "status", null: false
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_import_files_on_address_id"
    t.index ["job_id"], name: "index_import_files_on_job_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.text "summary", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ledger_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.integer "kind", null: false
    t.string "name", null: false
    t.string "summary"
    t.datetime "updated_at", null: false
  end

  create_table "ledgers", force: :cascade do |t|
    t.integer "address_id"
    t.datetime "created_at", null: false
    t.datetime "date", null: false
    t.integer "face_value", null: false
    t.integer "ledger_item_id"
    t.string "name", null: false
    t.decimal "proportion_amount"
    t.decimal "proportion_rate"
    t.integer "recorded_amount"
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_ledgers_on_address_id"
    t.index ["date", "name", "ledger_item_id"], name: "index_ledgers_unique_date_item_name", unique: true
    t.index ["ledger_item_id"], name: "index_ledgers_on_ledger_item_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "end_at", null: false
    t.string "message", null: false
    t.integer "priority", default: 1, null: false
    t.datetime "start_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "address_id", null: false
    t.integer "chain_id"
    t.datetime "created_at", null: false
    t.string "domain"
    t.string "ip_address"
    t.string "message"
    t.string "signature"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["address_id"], name: "index_sessions_on_address_id"
  end

  create_table "transaction_types", force: :cascade do |t|
    t.integer "address_id"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.integer "kind"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_transaction_types_on_address_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "import_files", "addresses"
  add_foreign_key "import_files", "jobs"
  add_foreign_key "sessions", "addresses"
end
