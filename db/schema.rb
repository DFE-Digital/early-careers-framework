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

ActiveRecord::Schema.define(version: 2021_07_08_125502) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "additional_school_emails", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "school_id", null: false
    t.string "email_address", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email_address", "school_id"], name: "index_additional_school_emails_on_email_address_and_school_id", unique: true
    t.index ["school_id"], name: "index_additional_school_emails_on_school_id"
  end

  create_table "admin_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_admin_profiles_on_discarded_at"
    t.index ["user_id"], name: "index_admin_profiles_on_user_id"
  end

  create_table "api_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "lead_provider_id"
    t.string "hashed_token", null: false
    t.datetime "last_used_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "type", default: "ApiToken"
    t.boolean "private_api_access", default: false
    t.uuid "cpd_lead_provider_id"
    t.index ["cpd_lead_provider_id"], name: "index_api_tokens_on_cpd_lead_provider_id"
    t.index ["hashed_token"], name: "index_api_tokens_on_hashed_token", unique: true
    t.index ["lead_provider_id"], name: "index_api_tokens_on_lead_provider_id"
  end

  create_table "call_off_contracts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "version", default: "0.0.1", null: false
    t.jsonb "raw"
    t.decimal "uplift_target"
    t.decimal "uplift_amount"
    t.integer "recruitment_target"
    t.decimal "set_up_fee"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "lead_provider_id", default: -> { "gen_random_uuid()" }, null: false
    t.index ["lead_provider_id"], name: "index_call_off_contracts_on_lead_provider_id"
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

  create_table "cpd_lead_providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "data_stage_school_changes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "data_stage_school_id", null: false
    t.json "attribute_changes"
    t.string "status", default: "changed", null: false
    t.boolean "handled", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["data_stage_school_id"], name: "index_data_stage_school_changes_on_data_stage_school_id"
    t.index ["status"], name: "index_data_stage_school_changes_on_status"
  end

  create_table "data_stage_school_links", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "data_stage_school_id", null: false
    t.string "link_urn", null: false
    t.string "link_type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["data_stage_school_id", "link_urn"], name: "data_stage_school_links_uniq_idx", unique: true
    t.index ["data_stage_school_id"], name: "index_data_stage_school_links_on_data_stage_school_id"
  end

  create_table "data_stage_schools", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "urn", null: false
    t.string "name", null: false
    t.string "ukprn"
    t.integer "school_phase_type"
    t.string "school_phase_name"
    t.integer "school_type_code"
    t.string "school_type_name"
    t.integer "school_status_code"
    t.string "school_status_name"
    t.string "administrative_district_code"
    t.string "administrative_district_name"
    t.string "address_line1", null: false
    t.string "address_line2"
    t.string "address_line3"
    t.string "postcode", null: false
    t.string "primary_contact_email"
    t.string "secondary_contact_email"
    t.string "school_website"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["urn"], name: "index_data_stage_schools_on_urn", unique: true
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

  create_table "event_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "owner_type", null: false
    t.uuid "owner_id", null: false
    t.string "event", null: false
    t.json "data", default: {}
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["owner_type", "owner_id"], name: "index_event_logs_on_owner"
  end

  create_table "feature_selected_objects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "object_type", null: false
    t.uuid "object_id", null: false
    t.uuid "feature_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["feature_id"], name: "index_feature_selected_objects_on_feature_id"
    t.index ["object_id", "feature_id", "object_type"], name: "unique_selected_object", unique: true
    t.index ["object_type", "object_id"], name: "index_feature_selected_objects_on_object"
  end

  create_table "features", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.boolean "active", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_features_on_name", unique: true
  end

  create_table "friendly_id_slugs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "induction_coordinator_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_induction_coordinator_profiles_on_discarded_at"
    t.index ["user_id"], name: "index_induction_coordinator_profiles_on_user_id"
  end

  create_table "induction_coordinator_profiles_schools", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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
    t.uuid "cpd_lead_provider_id"
    t.index ["cpd_lead_provider_id"], name: "index_lead_providers_on_cpd_lead_provider_id"
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
    t.uuid "partnership_notification_email_id"
    t.string "notify_id"
    t.datetime "delivered_at"
    t.index ["notify_id"], name: "index_nomination_emails_on_notify_id"
    t.index ["partnership_notification_email_id"], name: "index_nomination_emails_on_partnership_notification_email_id"
    t.index ["school_id"], name: "index_nomination_emails_on_school_id"
    t.index ["token"], name: "index_nomination_emails_on_token", unique: true
  end

  create_table "npq_courses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "npq_lead_providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "cpd_lead_provider_id"
    t.index ["cpd_lead_provider_id"], name: "index_npq_lead_providers_on_cpd_lead_provider_id"
  end

  create_table "npq_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "npq_lead_provider_id", null: false
    t.uuid "npq_course_id", null: false
    t.date "date_of_birth"
    t.text "teacher_reference_number"
    t.boolean "teacher_reference_number_verified", default: false
    t.text "school_urn"
    t.text "headteacher_status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "active_alert", default: false
    t.boolean "eligible_for_funding", default: false, null: false
    t.text "funding_choice"
    t.index ["npq_course_id"], name: "index_npq_profiles_on_npq_course_id"
    t.index ["npq_lead_provider_id"], name: "index_npq_profiles_on_npq_lead_provider_id"
    t.index ["user_id"], name: "index_npq_profiles_on_user_id"
  end

  create_table "participant_bands", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "call_off_contract_id", null: false
    t.integer "min"
    t.integer "max"
    t.decimal "per_participant"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["call_off_contract_id"], name: "index_participant_bands_on_call_off_contract_id"
  end

  create_table "participant_declarations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "lead_provider_id", null: false
    t.string "declaration_type"
    t.datetime "declaration_date"
    t.jsonb "raw_event"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "user_id", null: false
    t.index ["lead_provider_id"], name: "index_participant_declarations_on_lead_provider_id"
    t.index ["user_id"], name: "index_participant_declarations_on_user_id"
  end

  create_table "participant_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.json "object"
    t.json "object_changes"
    t.datetime "created_at"
    t.uuid "item_id", null: false
    t.index ["item_type", "item_id"], name: "index_participant_events_on_item_type_and_item_id"
  end

  create_table "participant_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type", null: false
    t.uuid "user_id", null: false
    t.uuid "school_id"
    t.uuid "core_induction_programme_id"
    t.uuid "cohort_id"
    t.uuid "mentor_profile_id"
    t.boolean "sparsity_uplift", default: false, null: false
    t.boolean "pupil_premium_uplift", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "status", default: "active", null: false
    t.index ["cohort_id"], name: "index_participant_profiles_on_cohort_id"
    t.index ["core_induction_programme_id"], name: "index_participant_profiles_on_core_induction_programme_id"
    t.index ["mentor_profile_id"], name: "index_participant_profiles_on_mentor_profile_id"
    t.index ["school_id"], name: "index_participant_profiles_on_school_id"
    t.index ["user_id"], name: "index_participant_profiles_on_user_id"
  end

  create_table "participation_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "early_career_teacher_profile_id", null: false
    t.string "state", default: "assigned", null: false
    t.uuid "lead_provider_id", null: false
    t.index ["early_career_teacher_profile_id"], name: "index_participation_records_on_early_career_teacher_profile_id"
    t.index ["lead_provider_id"], name: "index_participation_records_on_lead_provider_id"
  end

  create_table "partnership_csv_uploads", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "lead_provider_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "delivery_partner_id", null: false
    t.uuid "cohort_id"
    t.index ["cohort_id"], name: "index_partnership_csv_uploads_on_cohort_id"
    t.index ["delivery_partner_id"], name: "index_partnership_csv_uploads_on_delivery_partner_id"
    t.index ["lead_provider_id"], name: "index_partnership_csv_uploads_on_lead_provider_id"
  end

  create_table "partnership_notification_emails", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "token", null: false
    t.string "sent_to", null: false
    t.string "email_type", null: false
    t.string "notify_id"
    t.string "notify_status"
    t.datetime "delivered_at"
    t.uuid "partnership_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["notify_id"], name: "index_partnership_notification_emails_on_notify_id"
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
    t.datetime "challenged_at"
    t.string "challenge_reason"
    t.datetime "challenge_deadline"
    t.boolean "pending", default: false, null: false
    t.uuid "report_id"
    t.index ["cohort_id"], name: "index_partnerships_on_cohort_id"
    t.index ["delivery_partner_id"], name: "index_partnerships_on_delivery_partner_id"
    t.index ["lead_provider_id"], name: "index_partnerships_on_lead_provider_id"
    t.index ["pending"], name: "index_partnerships_on_pending"
    t.index ["school_id", "lead_provider_id", "cohort_id"], name: "unique_partnerships", unique: true
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

  create_table "profile_declarations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "participant_declaration_id", null: false
    t.uuid "participant_profile_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["participant_declaration_id"], name: "index_profile_declarations_on_participant_declaration_id"
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
    t.boolean "opt_out_of_updates", default: false, null: false
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
    t.string "slug"
    t.index ["name"], name: "index_schools_on_name"
    t.index ["network_id"], name: "index_schools_on_network_id"
    t.index ["slug"], name: "index_schools_on_slug", unique: true
    t.index ["urn"], name: "index_schools_on_urn", unique: true
  end

  create_table "sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "session_id", null: false
    t.jsonb "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "full_name", null: false
    t.citext "email", default: "", null: false
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "additional_school_emails", "schools"
  add_foreign_key "admin_profiles", "users"
  add_foreign_key "api_tokens", "cpd_lead_providers"
  add_foreign_key "api_tokens", "lead_providers", on_delete: :cascade
  add_foreign_key "call_off_contracts", "lead_providers"
  add_foreign_key "cohorts_lead_providers", "cohorts"
  add_foreign_key "cohorts_lead_providers", "lead_providers"
  add_foreign_key "data_stage_school_changes", "data_stage_schools"
  add_foreign_key "data_stage_school_links", "data_stage_schools"
  add_foreign_key "district_sparsities", "local_authority_districts"
  add_foreign_key "feature_selected_objects", "features"
  add_foreign_key "induction_coordinator_profiles", "users"
  add_foreign_key "lead_provider_cips", "cohorts"
  add_foreign_key "lead_provider_cips", "core_induction_programmes"
  add_foreign_key "lead_provider_cips", "lead_providers"
  add_foreign_key "lead_provider_profiles", "lead_providers"
  add_foreign_key "lead_provider_profiles", "users"
  add_foreign_key "lead_providers", "cpd_lead_providers"
  add_foreign_key "nomination_emails", "partnership_notification_emails"
  add_foreign_key "nomination_emails", "schools"
  add_foreign_key "npq_lead_providers", "cpd_lead_providers"
  add_foreign_key "participant_bands", "call_off_contracts"
  add_foreign_key "participant_declarations", "lead_providers"
  add_foreign_key "participant_profiles", "cohorts"
  add_foreign_key "participant_profiles", "core_induction_programmes"
  add_foreign_key "participant_profiles", "participant_profiles", column: "mentor_profile_id"
  add_foreign_key "participant_profiles", "schools"
  add_foreign_key "participant_profiles", "users"
  add_foreign_key "participation_records", "lead_providers"
  add_foreign_key "participation_records", "participant_profiles", column: "early_career_teacher_profile_id"
  add_foreign_key "partnership_notification_emails", "partnerships"
  add_foreign_key "partnerships", "cohorts"
  add_foreign_key "partnerships", "delivery_partners"
  add_foreign_key "partnerships", "lead_providers"
  add_foreign_key "partnerships", "schools"
  add_foreign_key "profile_declarations", "participant_profiles"
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
