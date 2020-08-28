# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_08_11_102207) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "indicators", force: :cascade do |t|
    t.string "indicator_name"
    t.string "indicator_symbol"
    t.string "response_keys", default: [], array: true
    t.integer "min_data_size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["indicator_name"], name: "index_indicators_on_indicator_name"
    t.index ["indicator_symbol"], name: "index_indicators_on_indicator_symbol"
  end

  create_table "marks", force: :cascade do |t|
    t.integer "indicator_id"
    t.integer "strategy_id"
    t.boolean "required", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.jsonb "options", default: {}
    t.string "fileset"
    t.jsonb "limits", default: []
    t.integer "operation", default: 0
    t.index ["indicator_id"], name: "index_marks_on_indicator_id"
    t.index ["strategy_id"], name: "index_marks_on_strategy_id"
  end

  create_table "strategies", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.integer "min_buy_required", default: 1
    t.integer "min_sell_required", default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_strategies_on_name"
    t.index ["user_id"], name: "index_strategies_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.index ["email"], name: "index_users_on_email"
  end

end
