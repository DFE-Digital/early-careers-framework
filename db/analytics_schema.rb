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

ActiveRecord::Schema.define(version: 2023_01_31_103200) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "ecf_appropriate_bodies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "appropriate_body_id"
    t.string "name"
    t.string "body_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "ecf_inductions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "induction_record_id"
    t.string "external_id"
    t.uuid "participant_profile_id"
    t.uuid "induction_programme_id"
    t.string "induction_programme_type"
    t.string "school_name"
    t.string "school_urn"
    t.string "schedule_id"
    t.uuid "mentor_id"
    t.uuid "appropriate_body_id"
    t.string "appropriate_body_name"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "induction_status"
    t.string "training_status"
    t.boolean "school_transfer"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "cohort_id"
    t.uuid "user_id"
    t.string "participant_type"
    t.datetime "induction_record_created_at"
    t.index ["induction_record_id"], name: "index_ecf_inductions_on_induction_record_id", unique: true
  end

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
    t.string "external_id"
    t.index ["participant_profile_id"], name: "index_ecf_participants_on_participant_profile_id"
  end

  create_table "ecf_partnerships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "partnership_id"
    t.uuid "school_id"
    t.string "school_name"
    t.string "school_urn"
    t.uuid "lead_provider_id"
    t.string "lead_provider_name"
    t.uuid "cohort_id"
    t.string "cohort"
    t.uuid "delivery_partner_id"
    t.string "delivery_partner_name"
    t.datetime "challenged_at"
    t.string "challenge_reason"
    t.datetime "challenge_deadline"
    t.boolean "pending"
    t.uuid "report_id"
    t.boolean "relationship"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "ecf_school_cohorts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "school_cohort_id"
    t.uuid "school_id"
    t.string "school_name"
    t.string "school_urn"
    t.uuid "cohort_id"
    t.string "cohort"
    t.string "induction_programme_choice"
    t.string "default_induction_programme_training_choice"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "appropriate_body_id"
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
