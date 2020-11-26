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

ActiveRecord::Schema.define(version: 2020_11_25_155842) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "lead_providers", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name", null: false
  end

  create_table "networks", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name", null: false
  end

  create_table "partnerships", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "school_id", null: false
    t.bigint "lead_provider_id", null: false
    t.datetime "confirmed_at"
    t.index ["lead_provider_id"], name: "index_partnerships_on_lead_provider_id"
    t.index ["school_id"], name: "index_partnerships_on_school_id"
  end

  create_table "schools", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "urn", null: false
    t.string "name", null: false
    t.string "address", null: false
    t.string "school_type"
    t.integer "capacity"
    t.boolean "high_pupil_premium", default: false, null: false
    t.boolean "is_rural", default: false, null: false
    t.bigint "network_id"
    t.index ["high_pupil_premium"], name: "index_schools_on_high_pupil_premium", where: "high_pupil_premium"
    t.index ["is_rural"], name: "index_schools_on_is_rural", where: "is_rural"
    t.index ["name"], name: "index_schools_on_name"
    t.index ["network_id"], name: "index_schools_on_network_id"
    t.index ["urn"], name: "index_schools_on_urn", unique: true
  end

  add_foreign_key "partnerships", "lead_providers"
  add_foreign_key "partnerships", "schools"
  add_foreign_key "schools", "networks"
end
