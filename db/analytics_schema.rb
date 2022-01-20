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

ActiveRecord::Schema.define(version: 2022_01_20_103423) do

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
    t.boolean "active", default: true
    t.string "training_status"
    t.boolean "sparsity"
    t.boolean "pupil_premium"
    t.string "schedule_identifier"
    t.index ["participant_profile_id"], name: "index_ecf_participants_on_participant_profile_id"
  end

  create_table "ecf_schools", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "urn"
    t.datetime "nomination_email_opened_at"
    t.boolean "induction_tutor_nominated"
    t.datetime "tutor_nominated_time"
    t.boolean "induction_tutor_signed_in"
    t.string "induction_programme_choice"
    t.boolean "in_partnership"
    t.datetime "partnership_time"
    t.string "partnership_challenge_reason"
    t.string "partnership_challenge_time"
    t.string "lead_provider"
    t.string "delivery_partner"
    t.string "chosen_cip"
    t.string "school_type_name"
    t.integer "school_phase_type"
    t.string "school_phase_name"
    t.integer "school_status_code"
    t.string "school_status_name"
    t.string "postcode"
    t.string "administrative_district_code"
    t.string "administrative_district_name"
    t.boolean "active_participants"
    t.boolean "pupil_premium"
    t.boolean "sparsity"
    t.index ["urn"], name: "index_ecf_schools_on_urn", unique: true
  end

end
