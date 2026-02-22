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

ActiveRecord::Schema[8.1].define(version: 2026_02_22_014159) do
  create_table "items", force: :cascade do |t|
    t.integer "action_type"
    t.datetime "created_at", null: false
    t.integer "energy"
    t.text "memo"
    t.datetime "snooze_until"
    t.integer "status", default: 0, null: false
    t.integer "time_bucket"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.integer "user_id", null: false
    t.index ["user_id", "status"], name: "index_items_on_user_id_and_status"
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.integer "now_item_id"
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.index ["now_item_id"], name: "index_users_on_now_item_id"
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
  end

  add_foreign_key "items", "users"
  add_foreign_key "users", "items", column: "now_item_id", on_delete: :nullify
end
