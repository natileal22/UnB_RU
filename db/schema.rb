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

ActiveRecord::Schema[8.1].define(version: 2026_11_11_161135) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accesses", force: :cascade do |t|
    t.bigint "restaurant_id", null: false
    t.string "catraca", null: false
    t.string "matricula", null: false
    t.string "resultado", null: false
    t.datetime "occurred_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["occurred_at"], name: "index_accesses_on_occurred_at"
    t.index ["restaurant_id", "catraca"], name: "index_accesses_on_restaurant_id_and_catraca"
    t.index ["restaurant_id"], name: "index_accesses_on_restaurant_id"
    t.index ["resultado"], name: "index_accesses_on_resultado"
  end

  create_table "restaurants", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_restaurants_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "matricula", null: false
    t.string "email"
    t.string "password", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["matricula"], name: "index_users_on_matricula", unique: true
  end

  add_foreign_key "accesses", "restaurants"
end
