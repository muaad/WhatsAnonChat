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

ActiveRecord::Schema.define(version: 20150527140535) do

  create_table "chats", force: :cascade do |t|
    t.integer  "contact_id"
    t.integer  "friend_id"
    t.boolean  "active",     default: true
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "commands", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "action_path"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "enabled",     default: false
  end

  create_table "contacts", force: :cascade do |t|
    t.string   "name"
    t.string   "phone_number"
    t.string   "gender"
    t.integer  "age"
    t.string   "country"
    t.string   "username"
    t.boolean  "opted_in",          default: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "channel"
    t.string   "password_digest"
    t.string   "auth_token"
    t.string   "verification_code"
    t.boolean  "verified",          default: false
    t.datetime "dob"
    t.boolean  "on_slack",          default: false
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "chat_id"
    t.text     "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "from"
    t.integer  "to"
  end

  add_index "messages", ["chat_id"], name: "index_messages_on_chat_id"

  create_table "progresses", force: :cascade do |t|
    t.integer  "contact_id"
    t.integer  "step_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "progresses", ["contact_id"], name: "index_progresses_on_contact_id"
  add_index "progresses", ["step_id"], name: "index_progresses_on_step_id"

  create_table "steps", force: :cascade do |t|
    t.string   "name"
    t.string   "step_type"
    t.integer  "next_step_id"
    t.text     "prompt"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

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
    t.string   "name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
