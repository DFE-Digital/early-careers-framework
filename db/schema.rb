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

ActiveRecord::Schema.define(version: 2021_01_19_093554) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "admin_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_admin_profiles_on_user_id"
  end

  create_table "induction_coordinator_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_induction_coordinator_profiles_on_user_id"
  end

  create_table "induction_coordinator_profiles_schools", id: false, force: :cascade do |t|
    t.uuid "induction_coordinator_profile_id", null: false
    t.uuid "school_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["induction_coordinator_profile_id"], name: "index_icp_schools_on_icp"
    t.index ["school_id"], name: "index_icp_schools_on_schools"
  end

  create_table "lead_provider_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "lead_provider_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lead_provider_id"], name: "index_lead_provider_profiles_on_lead_provider_id"
    t.index ["user_id"], name: "index_lead_provider_profiles_on_user_id"
  end

  create_table "lead_providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name", null: false
  end

  create_table "networks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name", null: false
  end

  create_table "partnerships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "school_id", null: false
    t.uuid "lead_provider_id", null: false
    t.datetime "confirmed_at"
    t.index ["lead_provider_id"], name: "index_partnerships_on_lead_provider_id"
    t.index ["school_id"], name: "index_partnerships_on_school_id"
  end

  create_table "schools", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "urn", null: false
    t.string "name", null: false
    t.string "school_type"
    t.integer "capacity"
    t.boolean "high_pupil_premium", default: false, null: false
    t.boolean "is_rural", default: false, null: false
    t.string "address_line1", null: false
    t.string "address_line2"
    t.string "address_line3"
    t.string "address_line4"
    t.string "country", null: false
    t.string "postcode", null: false
    t.uuid "network_id"
    t.string "domains", default: [], null: false, array: true
    t.boolean "eligible", default: true, null: false
    t.index ["high_pupil_premium"], name: "index_schools_on_high_pupil_premium", where: "high_pupil_premium"
    t.index ["is_rural"], name: "index_schools_on_is_rural", where: "is_rural"
    t.index ["name"], name: "index_schools_on_name"
    t.index ["network_id"], name: "index_schools_on_network_id"
    t.index ["urn"], name: "index_schools_on_urn", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "full_name", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "login_token"
    t.datetime "login_token_valid_until"
    t.datetime "remember_created_at"
    t.datetime "last_sign_in_at"
    t.datetime "current_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.integer "sign_in_count", default: 0, null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "admin_profiles", "users"
  add_foreign_key "induction_coordinator_profiles", "users"
  add_foreign_key "lead_provider_profiles", "lead_providers"
  add_foreign_key "lead_provider_profiles", "users"
  add_foreign_key "partnerships", "lead_providers"
  add_foreign_key "partnerships", "schools"
  add_foreign_key "schools", "networks"
end
