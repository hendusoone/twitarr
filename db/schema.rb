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

ActiveRecord::Schema.define(version: 2019_09_04_025735) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_locations_on_name", unique: true
  end

  create_table "registration_codes", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_registration_codes_on_code", unique: true
  end

  create_table "sections", force: :cascade do |t|
    t.string "name"
    t.boolean "enabled", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_sections_on_name", unique: true
  end

  create_table "stream_posts", force: :cascade do |t|
    t.bigint "author", null: false
    t.bigint "original_author", null: false
    t.string "text", null: false
    t.bigint "location_id"
    t.boolean "locked", default: false, null: false
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_chain", default: [], array: true
    t.index "to_tsvector('english'::regconfig, (text)::text)", name: "index_stream_posts_text", using: :gin
    t.index ["author"], name: "index_stream_posts_on_author"
    t.index ["location_id"], name: "index_stream_posts_on_location_id"
    t.index ["parent_chain"], name: "index_stream_posts_on_parent_chain", using: :gin
    t.index ["parent_id"], name: "index_stream_posts_on_parent_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "password"
    t.integer "role"
    t.string "status"
    t.string "email"
    t.string "display_name"
    t.datetime "last_login"
    t.datetime "last_viewed_alerts"
    t.string "photo_hash"
    t.datetime "last_photo_updated", default: -> { "now()" }, null: false
    t.string "room_number"
    t.string "real_name"
    t.string "home_location"
    t.string "current_location"
    t.string "registration_code"
    t.string "pronouns"
    t.string "mute_reason"
    t.string "ban_reason"
    t.string "mute_thread"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["display_name"], name: "index_users_on_display_name"
    t.index ["registration_code"], name: "index_users_on_registration_code", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "stream_posts", "locations", on_delete: :nullify
  add_foreign_key "stream_posts", "stream_posts", column: "parent_id", on_delete: :nullify
  add_foreign_key "stream_posts", "users", column: "author", on_delete: :cascade
  add_foreign_key "stream_posts", "users", column: "original_author", on_delete: :cascade
end
