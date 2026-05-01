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

ActiveRecord::Schema[7.0].define(version: 2026_05_01_082051) do
  create_table "darts", force: :cascade do |t|
    t.integer "record_round_id"
    t.integer "segment", null: false
    t.integer "multiplier", null: false
    t.integer "number", null: false
    t.integer "absolute_r"
    t.decimal "absolute_0", precision: 6, scale: 3
    t.integer "index_r"
    t.integer "index_n"
    t.integer "target"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "game_round_id"
    t.index ["game_round_id"], name: "index_darts_on_game_round_id"
    t.index ["record_round_id"], name: "index_darts_on_record_round_id"
    t.check_constraint "(record_round_id IS NOT NULL AND game_round_id IS NULL) OR (record_round_id IS NULL AND game_round_id IS NOT NULL)", name: "check_darts_parent"
  end

  create_table "game_rounds", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "score", null: false
    t.integer "hit", default: 0, null: false
    t.float "range"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_game_rounds_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "number", null: false
    t.float "stats", null: false
    t.integer "turn_number", null: false
    t.integer "type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_games_on_user_id"
  end

  create_table "record_rounds", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "hit", default: 0, null: false
    t.float "range"
    t.index ["user_id"], name: "index_record_rounds_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.integer "gender"
    t.date "birthday"
    t.string "experience"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "darts", "record_rounds"
  add_foreign_key "game_rounds", "games"
  add_foreign_key "games", "users"
  add_foreign_key "record_rounds", "users"
end
