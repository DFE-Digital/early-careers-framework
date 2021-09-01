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

ActiveRecord::Schema.define(version: 2021_09_01_101452) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "ecf_participants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "user_id"
    t.datetime "user_created_at"
    t.integer "real_time_attempts"
    t.boolean "real_time_success"
    t.datetime "validation_submitted_at"
    t.boolean "trn_verified"
    t.string "school_urn"
    t.string "school_name"
    t.string "establishment_phase_name"
    t.string "participant_type"
    t.string "participant_profile_id"
    t.string "cohort"
    t.string "mentor_id"
    t.boolean "nino_entered"
    t.boolean "manually_validated"
    t.boolean "eligible_for_funding"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["participant_profile_id"], name: "index_ecf_participants_on_participant_profile_id"
  end

end
