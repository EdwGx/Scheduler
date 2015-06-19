# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150603210717) do

  create_table "alliances", force: :cascade do |t|
    t.integer  "match_id"
    t.boolean  "home",                 default: false, null: false
    t.string   "result",     limit: 8
    t.integer  "point",                default: 0
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "alliances", ["match_id"], name: "index_alliances_on_match_id"

  create_table "alliances_teams", force: :cascade do |t|
    t.integer "alliance_id"
    t.integer "team_id"
  end

  add_index "alliances_teams", ["alliance_id"], name: "index_alliances_teams_on_alliance_id"
  add_index "alliances_teams", ["team_id"], name: "index_alliances_teams_on_team_id"

  create_table "fields", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "location"
    t.integer  "user_id",    null: false
    t.integer  "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "fields", ["team_id"], name: "index_fields_on_team_id"
  add_index "fields", ["user_id"], name: "index_fields_on_user_id"

  create_table "matches", force: :cascade do |t|
    t.datetime "start_at"
    t.integer  "duration"
    t.integer  "tournament_id", null: false
    t.integer  "field_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "matches", ["field_id"], name: "index_matches_on_field_id"
  add_index "matches", ["tournament_id"], name: "index_matches_on_tournament_id"

  create_table "players", force: :cascade do |t|
    t.string  "name"
    t.string  "email"
    t.string  "info",     default: "[]"
    t.boolean "verified", default: false, null: false
    t.integer "team_id"
  end

  add_index "players", ["team_id"], name: "index_players_on_team_id"

  create_table "teams", force: :cascade do |t|
    t.string   "name",                               null: false
    t.integer  "user_id",                            null: false
    t.boolean  "allow_registration", default: false, null: false
    t.string   "registration_token"
    t.string   "players_info",       default: "[]"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "teams", ["registration_token"], name: "index_teams_on_registration_token"
  add_index "teams", ["user_id"], name: "index_teams_on_user_id"

  create_table "timeslots", force: :cascade do |t|
    t.integer  "field_id"
    t.integer  "match_id"
    t.datetime "start_at"
    t.integer  "duration"
    t.datetime "end_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "timeslots", ["field_id"], name: "index_timeslots_on_field_id"
  add_index "timeslots", ["match_id"], name: "index_timeslots_on_match_id"

  create_table "tournaments", force: :cascade do |t|
    t.string   "name",       null: false
    t.integer  "user_id",    null: false
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "tournaments", ["user_id"], name: "index_tournaments_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
