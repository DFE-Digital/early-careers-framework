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

ActiveRecord::Schema[7.0].define(version: 2023_11_09_124740) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gin"
  enable_extension "citext"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "applications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_id", null: false
    t.bigint "lead_provider_id", null: false
    t.text "school_urn"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "ecf_id"
    t.text "headteacher_status"
    t.boolean "eligible_for_funding", default: false, null: false
    t.text "funding_choice"
    t.text "ukprn"
    t.text "teacher_catchment"
    t.text "teacher_catchment_country"
    t.boolean "works_in_school"
    t.string "employer_name"
    t.string "employment_role"
    t.text "private_childcare_provider_urn"
    t.boolean "works_in_nursery"
    t.boolean "works_in_childcare"
    t.text "kind_of_nursery"
    t.integer "DEPRECATED_cohort"
    t.boolean "targeted_delivery_funding_eligibility", default: false
    t.string "funding_eligiblity_status_code"
    t.jsonb "raw_application_data", default: {}
    t.text "work_setting"
    t.boolean "teacher_catchment_synced_to_ecf", default: false
    t.string "employment_type"
    t.string "itt_provider"
    t.boolean "lead_mentor", default: false
    t.boolean "primary_establishment", default: false
    t.integer "number_of_pupils", default: 0
    t.boolean "tsf_primary_eligibility", default: false
    t.boolean "tsf_primary_plus_eligibility", default: false
    t.text "lead_provider_approval_status"
    t.text "participant_outcome_state"
    t.index ["course_id"], name: "index_applications_on_course_id"
    t.index ["lead_provider_id"], name: "index_applications_on_lead_provider_id"
    t.index ["user_id"], name: "index_applications_on_user_id"
  end

  create_table "courses", force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "ecf_id"
    t.text "description"
    t.integer "position", default: 0
    t.boolean "display", default: true
    t.string "identifier"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "cron"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "ecf_sync_request_logs", force: :cascade do |t|
    t.integer "syncable_id", null: false
    t.string "syncable_type", null: false
    t.string "status", null: false
    t.string "sync_type", null: false
    t.jsonb "error_messages", default: []
    t.jsonb "response_body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["syncable_id", "syncable_type"], name: "index_ecf_sync_request_logs_on_syncable_id_and_syncable_type"
  end

  create_table "flipper_features", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.string "feature_key", null: false
    t.string "key", null: false
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "get_an_identity_webhook_messages", force: :cascade do |t|
    t.jsonb "raw"
    t.jsonb "message"
    t.string "message_id"
    t.string "message_type"
    t.string "status", default: "pending"
    t.string "status_comment"
    t.datetime "sent_at", precision: nil
    t.datetime "processed_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "itt_providers", force: :cascade do |t|
    t.text "legal_name"
    t.text "operating_name"
    t.datetime "removed_at", precision: nil
    t.boolean "approved"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legal_name"], name: "index_itt_providers_on_legal_name", unique: true
  end

  create_table "lead_providers", force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "ecf_id"
    t.string "hint"
  end

  create_table "local_authorities", force: :cascade do |t|
    t.text "ukprn"
    t.text "name"
    t.text "address_1"
    t.text "address_2"
    t.text "address_3"
    t.text "town"
    t.text "county"
    t.text "postcode"
    t.text "postcode_without_spaces"
    t.boolean "high_pupil_premium", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ukprn"], name: "index_local_authorities_on_ukprn"
  end

  create_table "private_childcare_providers", force: :cascade do |t|
    t.text "provider_urn", null: false
    t.text "provider_name"
    t.text "registered_person_urn"
    t.text "registered_person_name"
    t.text "registration_date"
    t.text "provider_status"
    t.text "address_1"
    t.text "address_2"
    t.text "address_3"
    t.text "town"
    t.text "postcode"
    t.text "postcode_without_spaces"
    t.text "region"
    t.text "local_authority"
    t.text "ofsted_region"
    t.json "early_years_individual_registers", default: []
    t.boolean "provider_early_years_register_flag"
    t.boolean "provider_compulsory_childcare_register_flag"
    t.integer "places"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_urn"], name: "index_private_childcare_providers_on_provider_urn"
  end

  create_table "registration_interests", force: :cascade do |t|
    t.citext "email", null: false
    t.boolean "notified", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_registration_interests_on_email", unique: true
  end

  create_table "reports", force: :cascade do |t|
    t.text "identifier", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "schools", force: :cascade do |t|
    t.text "urn", null: false
    t.text "la_code"
    t.text "la_name"
    t.text "establishment_number"
    t.text "name"
    t.text "establishment_status_code"
    t.text "establishment_status_name"
    t.date "close_date"
    t.text "ukprn"
    t.date "last_changed_date"
    t.text "address_1"
    t.text "address_2"
    t.text "address_3"
    t.text "town"
    t.text "county"
    t.text "postcode"
    t.integer "easting"
    t.integer "northing"
    t.text "region"
    t.text "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "establishment_type_code"
    t.text "establishment_type_name"
    t.boolean "high_pupil_premium", default: false, null: false
    t.text "postcode_without_spaces"
    t.integer "number_of_pupils"
    t.boolean "eyl_funding_eligible", default: false
    t.integer "phase_type", default: 0
    t.string "phase_name", default: "Not applicable"
    t.index "to_tsvector('english'::regconfig, COALESCE(name, ''::text))", name: "school_name_search_idx", using: :gin
    t.index ["urn"], name: "index_schools_on_urn"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "ecf_id"
    t.text "trn"
    t.text "full_name"
    t.text "otp_hash"
    t.datetime "otp_expires_at", precision: nil
    t.date "date_of_birth"
    t.boolean "trn_verified", default: false, null: false
    t.boolean "active_alert", default: false
    t.text "national_insurance_number"
    t.boolean "trn_auto_verified", default: false
    t.boolean "admin", default: false
    t.string "feature_flag_id"
    t.string "provider"
    t.string "uid"
    t.jsonb "raw_tra_provider_data"
    t.boolean "get_an_identity_id_synced_to_ecf", default: false
    t.boolean "super_admin", default: false, null: false
    t.datetime "updated_from_tra_at", precision: nil
    t.string "trn_lookup_status"
    t.index ["ecf_id"], name: "index_users_on_ecf_id"
    t.index ["email"], name: "index_users_on_email"
    t.index ["provider"], name: "index_users_on_provider"
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

end
