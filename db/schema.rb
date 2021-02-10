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

ActiveRecord::Schema.define(version: 2021_02_10_111857) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "admin_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_admin_profiles_on_user_id"
  end

  create_table "cohorts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "start_year", limit: 2, null: false
  end

  create_table "cohorts_lead_providers", id: false, force: :cascade do |t|
    t.uuid "lead_provider_id", null: false
    t.uuid "cohort_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["cohort_id", "lead_provider_id"], name: "index_cohorts_lead_providers_on_cohort_id_and_lead_provider_id"
    t.index ["lead_provider_id", "cohort_id"], name: "index_cohorts_lead_providers_on_lead_provider_id_and_cohort_id"
  end

  create_table "core_induction_programmes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "delayed_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "cron"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "delivery_partner_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "delivery_partner_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["delivery_partner_id"], name: "index_delivery_partner_profiles_on_delivery_partner_id"
    t.index ["user_id"], name: "index_delivery_partner_profiles_on_user_id"
  end

  create_table "delivery_partners", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name", null: false
  end

  create_table "early_career_teacher_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "school_id", null: false
    t.uuid "core_induction_programme_id"
    t.uuid "cohort_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["cohort_id"], name: "index_early_career_teacher_profiles_on_cohort_id"
    t.index ["core_induction_programme_id"], name: "index_ect_profiles_on_core_induction_programme_id"
    t.index ["school_id"], name: "index_early_career_teacher_profiles_on_school_id"
    t.index ["user_id"], name: "index_early_career_teacher_profiles_on_user_id"
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

  create_table "lead_provider_cips", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "lead_provider_id", null: false
    t.uuid "cohort_id", null: false
    t.uuid "core_induction_programme_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["cohort_id"], name: "index_lead_provider_cips_on_cohort_id"
    t.index ["core_induction_programme_id"], name: "index_lead_provider_cips_on_core_induction_programme_id"
    t.index ["lead_provider_id"], name: "index_lead_provider_cips_on_lead_provider_id"
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

  create_table "local_authorities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "code"
    t.string "name"
    t.index ["code"], name: "index_local_authorities_on_code", unique: true
  end

  create_table "local_authority_districts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "code"
    t.string "name"
    t.index ["code"], name: "index_local_authority_districts_on_code", unique: true
  end

  create_table "networks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name", null: false
    t.string "group_type"
    t.string "group_type_code"
    t.string "group_id"
    t.string "group_uid"
    t.string "secondary_contact_email"
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

  create_table "provider_relationships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "lead_provider_id", null: false
    t.uuid "delivery_partner_id", null: false
    t.uuid "cohort_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["cohort_id"], name: "index_provider_relationships_on_cohort_id"
    t.index ["delivery_partner_id"], name: "index_provider_relationships_on_delivery_partner_id"
    t.index ["lead_provider_id"], name: "index_provider_relationships_on_lead_provider_id"
  end

  create_table "schools", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "urn", null: false
    t.string "name", null: false
    t.string "school_type_code"
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
    t.uuid "local_authority_district_id"
    t.uuid "local_authority_id"
    t.string "school_type_name"
    t.string "ukprn"
    t.string "previous_school_urn"
    t.string "school_phase_type"
    t.string "school_phase_name"
    t.string "school_website"
    t.string "school_status_code"
    t.string "school_status_name"
    t.string "secondary_contact_email"
    t.string "primary_contact_email"
    t.index ["high_pupil_premium"], name: "index_schools_on_high_pupil_premium", where: "high_pupil_premium"
    t.index ["is_rural"], name: "index_schools_on_is_rural", where: "is_rural"
    t.index ["local_authority_district_id"], name: "index_schools_on_local_authority_district_id"
    t.index ["local_authority_id"], name: "index_schools_on_local_authority_id"
    t.index ["name"], name: "index_schools_on_name"
    t.index ["network_id"], name: "index_schools_on_network_id"
    t.index ["urn"], name: "index_schools_on_urn", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "full_name", null: false
    t.string "email", default: "", null: false
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
  add_foreign_key "cohorts_lead_providers", "cohorts"
  add_foreign_key "cohorts_lead_providers", "lead_providers"
  add_foreign_key "delivery_partner_profiles", "delivery_partners"
  add_foreign_key "delivery_partner_profiles", "users"
  add_foreign_key "early_career_teacher_profiles", "cohorts"
  add_foreign_key "early_career_teacher_profiles", "core_induction_programmes"
  add_foreign_key "early_career_teacher_profiles", "schools"
  add_foreign_key "early_career_teacher_profiles", "users"
  add_foreign_key "induction_coordinator_profiles", "users"
  add_foreign_key "lead_provider_cips", "cohorts"
  add_foreign_key "lead_provider_cips", "core_induction_programmes"
  add_foreign_key "lead_provider_cips", "lead_providers"
  add_foreign_key "lead_provider_profiles", "lead_providers"
  add_foreign_key "lead_provider_profiles", "users"
  add_foreign_key "partnerships", "lead_providers"
  add_foreign_key "partnerships", "schools"
  add_foreign_key "provider_relationships", "cohorts"
  add_foreign_key "provider_relationships", "delivery_partners"
  add_foreign_key "provider_relationships", "lead_providers"
  add_foreign_key "schools", "local_authorities"
  add_foreign_key "schools", "local_authority_districts"
  add_foreign_key "schools", "networks"
end
