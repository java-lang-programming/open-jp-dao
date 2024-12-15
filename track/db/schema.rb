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

ActiveRecord::Schema[8.0].define(version: 2024_12_13_000239) do
  create_table "addresses", force: :cascade do |t|
    t.string "address"
    t.integer "kind"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dollar_yen_transactions", force: :cascade do |t|
    t.integer "transaction_type_id"
    t.date "date", null: false
    t.decimal "deposit_rate"
    t.decimal "deposit_quantity"
    t.decimal "deposit_en"
    t.decimal "withdrawal_rate"
    t.decimal "withdrawal_quantity"
    t.decimal "withdrawal_en"
    t.decimal "exchange_en"
    t.decimal "exchange_difference"
    t.decimal "balance_rate", null: false
    t.decimal "balance_quantity", null: false
    t.decimal "balance_en", null: false
    t.integer "address_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_dollar_yen_transactions_on_address_id"
    t.index ["transaction_type_id"], name: "index_dollar_yen_transactions_on_transaction_type_id"
  end

  create_table "dollar_yens", force: :cascade do |t|
    t.date "date"
    t.decimal "dollar_yen_nakane", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_dollar_yens_on_date", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "address_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.integer "chain_id"
    t.string "message"
    t.string "signature"
    t.string "domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_sessions_on_address_id"
  end

  create_table "transaction_types", force: :cascade do |t|
    t.string "name"
    t.integer "kind"
    t.integer "address_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_transaction_types_on_address_id"
  end

  add_foreign_key "sessions", "addresses"
end
