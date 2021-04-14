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

ActiveRecord::Schema.define(version: 2021_04_19_142255) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "admin_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_admin_profiles_on_discarded_at"
    t.index ["user_id"], name: "index_admin_profiles_on_user_id"
  end

  create_table "cohorts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "start_year", limit: 2, null: false
    t.index ["start_year"], name: "index_cohorts_on_start_year", unique: true
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

  create_table "delivery_partners", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_delivery_partners_on_discarded_at"
  end

  create_table "district_sparsities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "local_authority_district_id", null: false
    t.integer "start_year", limit: 2, null: false
    t.integer "end_year", limit: 2
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["local_authority_district_id"], name: "index_district_sparsities_on_local_authority_district_id"
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
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_induction_coordinator_profiles_on_discarded_at"
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
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_lead_provider_profiles_on_discarded_at"
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

  create_table "nomination_emails", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "token", null: false
    t.string "notify_status"
    t.string "sent_to", null: false
    t.datetime "sent_at"
    t.datetime "opened_at"
    t.uuid "school_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["school_id"], name: "index_nomination_emails_on_school_id"
    t.index ["token"], name: "index_nomination_emails_on_token", unique: true
  end

  create_table "partnership_notification_emails", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "token", null: false
    t.string "sent_to", null: false
    t.string "notify_id"
    t.string "notify_status"
    t.datetime "delivered_at"
    t.uuid "partnership_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["partnership_id"], name: "index_partnership_notification_emails_on_partnership_id"
    t.index ["token"], name: "index_partnership_notification_emails_on_token", unique: true
  end

  create_table "partnerships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "school_id", null: false
    t.uuid "lead_provider_id", null: false
    t.uuid "cohort_id", null: false
    t.uuid "delivery_partner_id"
    t.index ["cohort_id"], name: "index_partnerships_on_cohort_id"
    t.index ["delivery_partner_id"], name: "index_partnerships_on_delivery_partner_id"
    t.index ["lead_provider_id"], name: "index_partnerships_on_lead_provider_id"
    t.index ["school_id"], name: "index_partnerships_on_school_id"
  end

  create_table "privacy_policies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "major_version", null: false
    t.integer "minor_version", null: false
    t.text "html", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["major_version", "minor_version"], name: "index_privacy_policies_on_major_version_and_minor_version", unique: true
  end

  create_table "privacy_policy_acceptances", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "privacy_policy_id"
    t.uuid "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["privacy_policy_id", "user_id"], name: "single-acceptance", unique: true
  end

  create_table "provider_relationships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "lead_provider_id", null: false
    t.uuid "delivery_partner_id", null: false
    t.uuid "cohort_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "discarded_at"
    t.index ["cohort_id"], name: "index_provider_relationships_on_cohort_id"
    t.index ["delivery_partner_id"], name: "index_provider_relationships_on_delivery_partner_id"
    t.index ["discarded_at"], name: "index_provider_relationships_on_discarded_at"
    t.index ["lead_provider_id"], name: "index_provider_relationships_on_lead_provider_id"
  end

  create_table "pupil_premiums", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "school_id", null: false
    t.integer "start_year", limit: 2, null: false
    t.integer "total_pupils", null: false
    t.integer "eligible_pupils", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["school_id"], name: "index_pupil_premiums_on_school_id"
  end

  create_table "school_cohorts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "induction_programme_choice", null: false
    t.uuid "school_id", null: false
    t.uuid "cohort_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "estimated_teacher_count"
    t.integer "estimated_mentor_count"
    t.uuid "core_induction_programme_id"
    t.index ["cohort_id"], name: "index_school_cohorts_on_cohort_id"
    t.index ["core_induction_programme_id"], name: "index_school_cohorts_on_core_induction_programme_id"
    t.index ["school_id"], name: "index_school_cohorts_on_school_id"
  end

  create_table "school_local_authorities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "school_id", null: false
    t.uuid "local_authority_id", null: false
    t.integer "start_year", limit: 2, null: false
    t.integer "end_year", limit: 2
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["local_authority_id"], name: "index_school_local_authorities_on_local_authority_id"
    t.index ["school_id"], name: "index_school_local_authorities_on_school_id"
  end

  create_table "school_local_authority_districts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "school_id", null: false
    t.uuid "local_authority_district_id", null: false
    t.integer "start_year", limit: 2, null: false
    t.integer "end_year", limit: 2
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["local_authority_district_id"], name: "index_schools_lads_on_lad_id"
    t.index ["school_id"], name: "index_school_local_authority_districts_on_school_id"
  end

  create_table "schools", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "urn", null: false
    t.string "name", null: false
    t.integer "school_type_code"
    t.string "address_line1", null: false
    t.string "address_line2"
    t.string "address_line3"
    t.string "postcode", null: false
    t.uuid "network_id"
    t.string "domains", default: [], null: false, array: true
    t.string "school_type_name"
    t.string "ukprn"
    t.integer "school_phase_type"
    t.string "school_phase_name"
    t.string "school_website"
    t.integer "school_status_code"
    t.string "school_status_name"
    t.string "secondary_contact_email"
    t.string "primary_contact_email"
    t.string "administrative_district_code"
    t.string "administrative_district_name"
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
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "versions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.json "object"
    t.json "object_changes"
    t.datetime "created_at"
    t.uuid "item_id", default: -> { "gen_random_uuid()" }, null: false
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "admin_profiles", "users"
  add_foreign_key "cohorts_lead_providers", "cohorts"
  add_foreign_key "cohorts_lead_providers", "lead_providers"
  add_foreign_key "district_sparsities", "local_authority_districts"
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
  add_foreign_key "nomination_emails", "schools"
  add_foreign_key "partnership_notification_emails", "partnerships"
  add_foreign_key "partnerships", "cohorts"
  add_foreign_key "partnerships", "delivery_partners"
  add_foreign_key "partnerships", "lead_providers"
  add_foreign_key "partnerships", "schools"
  add_foreign_key "provider_relationships", "cohorts"
  add_foreign_key "provider_relationships", "delivery_partners"
  add_foreign_key "provider_relationships", "lead_providers"
  add_foreign_key "pupil_premiums", "schools"
  add_foreign_key "school_cohorts", "cohorts"
  add_foreign_key "school_cohorts", "core_induction_programmes"
  add_foreign_key "school_cohorts", "schools"
  add_foreign_key "school_local_authorities", "local_authorities"
  add_foreign_key "school_local_authorities", "schools"
  add_foreign_key "school_local_authority_districts", "local_authority_districts"
  add_foreign_key "school_local_authority_districts", "schools"
  add_foreign_key "schools", "networks"
end
