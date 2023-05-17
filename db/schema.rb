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

ActiveRecord::Schema.define(version: 2023_05_10_225308) do

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
    t.boolean "super_user", default: false
    t.index ["discarded_at"], name: "index_admin_profiles_on_discarded_at"
    t.index ["user_id"], name: "index_admin_profiles_on_user_id"
  end

  create_table "api_request_audits", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "path"
    t.jsonb "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "api_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "request_path"
    t.integer "status_code"
    t.jsonb "request_headers"
    t.jsonb "request_body"
    t.jsonb "response_body"
    t.string "request_method"
    t.jsonb "response_headers"
    t.uuid "cpd_lead_provider_id"
    t.string "user_description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["cpd_lead_provider_id"], name: "index_api_requests_on_cpd_lead_provider_id"
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

  create_table "appropriate_bodies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "body_type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["body_type", "name"], name: "index_appropriate_bodies_on_body_type_and_name", unique: true
  end

  create_table "appropriate_body_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "appropriate_body_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["appropriate_body_id"], name: "index_appropriate_body_profiles_on_appropriate_body_id"
    t.index ["user_id"], name: "index_appropriate_body_profiles_on_user_id"
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
    t.integer "revised_target"
    t.uuid "cohort_id", null: false
    t.decimal "monthly_service_fee"
    t.index ["cohort_id"], name: "index_call_off_contracts_on_cohort_id"
    t.index ["lead_provider_id"], name: "index_call_off_contracts_on_lead_provider_id"
  end

  create_table "cohorts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "start_year", limit: 2, null: false
    t.datetime "registration_start_date"
    t.datetime "academic_year_start_date"
    t.datetime "npq_registration_start_date"
    t.date "automatic_assignment_period_end_date"
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
    t.boolean "section_41_approved"
    t.string "la_code"
    t.index ["urn"], name: "index_data_stage_schools_on_urn", unique: true
  end

  create_table "declaration_states", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "participant_declaration_id", null: false
    t.string "state", default: "submitted", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "state_reason"
    t.index ["participant_declaration_id"], name: "index_declaration_states_on_participant_declaration_id"
  end

  create_table "deleted_duplicates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "data"
    t.uuid "primary_participant_profile_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["primary_participant_profile_id"], name: "index_deleted_duplicates_on_primary_participant_profile_id"
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

  create_table "ecf_ineligible_participants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "trn"
    t.string "reason", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["trn"], name: "index_ecf_ineligible_participants_on_trn", unique: true
  end

  create_table "ecf_participant_eligibilities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "participant_profile_id", null: false
    t.boolean "qts"
    t.boolean "active_flags"
    t.boolean "previous_participation"
    t.boolean "previous_induction"
    t.boolean "manually_validated", default: false
    t.string "status", default: "manual_check", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "reason", default: "none", null: false
    t.boolean "different_trn"
    t.boolean "no_induction"
    t.boolean "exempt_from_induction"
    t.index ["participant_profile_id"], name: "index_ecf_participant_eligibilities_on_participant_profile_id", unique: true
  end

  create_table "ecf_participant_validation_data", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "participant_profile_id", null: false
    t.string "full_name"
    t.date "date_of_birth"
    t.string "trn"
    t.string "nino"
    t.boolean "api_failure", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["participant_profile_id"], name: "index_ecf_participant_validation_data_on_participant_profile_id", unique: true
  end

  create_table "email_associations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "email_id", null: false
    t.string "object_type", null: false
    t.uuid "object_id", null: false
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email_id"], name: "index_email_associations_on_email_id"
    t.index ["object_type", "object_id"], name: "index_email_associations_on_object"
  end

  create_table "emails", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "from"
    t.string "to", array: true
    t.uuid "template_id"
    t.integer "template_version"
    t.string "uri"
    t.jsonb "personalisation"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status", default: "submitted", null: false
    t.datetime "delivered_at"
    t.string "tags", default: [], null: false, array: true
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

  create_table "finance_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_finance_profiles_on_user_id"
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
    t.datetime "reminder_email_sent_at"
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

  create_table "induction_programmes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "school_cohort_id", null: false
    t.uuid "partnership_id"
    t.uuid "core_induction_programme_id"
    t.string "training_programme", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "delivery_partner_to_be_confirmed", default: false
    t.index ["core_induction_programme_id"], name: "index_induction_programmes_on_core_induction_programme_id"
    t.index ["partnership_id"], name: "index_induction_programmes_on_partnership_id"
    t.index ["school_cohort_id"], name: "index_induction_programmes_on_school_cohort_id"
  end

  create_table "induction_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "induction_programme_id", null: false
    t.uuid "participant_profile_id", null: false
    t.uuid "schedule_id", null: false
    t.datetime "start_date", null: false
    t.datetime "end_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "training_status", default: "active", null: false
    t.uuid "preferred_identity_id"
    t.string "induction_status", default: "active", null: false
    t.uuid "mentor_profile_id"
    t.boolean "school_transfer", default: false, null: false
    t.uuid "appropriate_body_id"
    t.index ["appropriate_body_id"], name: "index_induction_records_on_appropriate_body_id"
    t.index ["created_at"], name: "index_induction_records_on_created_at"
    t.index ["end_date"], name: "index_induction_records_on_end_date"
    t.index ["induction_programme_id"], name: "index_induction_records_on_induction_programme_id"
    t.index ["mentor_profile_id"], name: "index_induction_records_on_mentor_profile_id"
    t.index ["participant_profile_id"], name: "index_induction_records_on_participant_profile_id"
    t.index ["preferred_identity_id"], name: "index_induction_records_on_preferred_identity_id"
    t.index ["schedule_id"], name: "index_induction_records_on_schedule_id"
    t.index ["start_date"], name: "index_induction_records_on_start_date"
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
    t.boolean "vat_chargeable", default: true
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

  create_table "milestones", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "name", null: false
    t.date "milestone_date"
    t.date "payment_date", null: false
    t.uuid "schedule_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "start_date"
    t.string "declaration_type"
    t.index ["schedule_id"], name: "index_milestones_on_schedule_id"
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

  create_table "npq_application_eligibility_imports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "filename"
    t.string "status", default: "pending"
    t.integer "updated_records"
    t.jsonb "import_errors", default: []
    t.datetime "processed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_npq_application_eligibility_imports_on_user_id"
  end

  create_table "npq_application_exports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.uuid "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_npq_application_exports_on_user_id"
  end

  create_table "npq_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "npq_lead_provider_id", null: false
    t.uuid "npq_course_id", null: false
    t.date "date_of_birth"
    t.text "teacher_reference_number"
    t.boolean "teacher_reference_number_verified", default: false
    t.text "school_urn"
    t.text "headteacher_status"
    t.boolean "active_alert", default: false
    t.boolean "eligible_for_funding", default: false, null: false
    t.text "funding_choice"
    t.text "nino"
    t.text "lead_provider_approval_status", default: "pending", null: false
    t.text "school_ukprn"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "participant_identity_id"
    t.boolean "works_in_school"
    t.string "employer_name"
    t.string "employment_role"
    t.boolean "targeted_support_funding_eligibility", default: false
    t.uuid "cohort_id"
    t.boolean "targeted_delivery_funding_eligibility", default: false
    t.boolean "works_in_nursery"
    t.boolean "works_in_childcare"
    t.string "kind_of_nursery"
    t.string "private_childcare_provider_urn"
    t.string "funding_eligiblity_status_code"
    t.text "teacher_catchment"
    t.text "teacher_catchment_country"
    t.string "employment_type"
    t.string "teacher_catchment_iso_country_code", limit: 3
    t.string "itt_provider"
    t.boolean "lead_mentor", default: false
    t.string "notes"
    t.boolean "primary_establishment", default: false
    t.integer "number_of_pupils", default: 0
    t.boolean "tsf_primary_eligibility", default: false
    t.boolean "tsf_primary_plus_eligibility", default: false
    t.index ["cohort_id"], name: "index_npq_applications_on_cohort_id"
    t.index ["npq_course_id"], name: "index_npq_applications_on_npq_course_id"
    t.index ["npq_lead_provider_id"], name: "index_npq_applications_on_npq_lead_provider_id"
    t.index ["participant_identity_id"], name: "index_npq_applications_on_participant_identity_id"
  end

  create_table "npq_contracts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "raw"
    t.string "version", default: "0.0.1"
    t.uuid "npq_lead_provider_id", null: false
    t.integer "recruitment_target"
    t.string "course_identifier"
    t.integer "service_fee_installments"
    t.integer "service_fee_percentage", default: 40
    t.decimal "per_participant"
    t.integer "number_of_payment_periods"
    t.integer "output_payment_percentage", default: 60
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "cohort_id", null: false
    t.decimal "monthly_service_fee"
    t.decimal "targeted_delivery_funding_per_participant", default: "100.0"
    t.index ["cohort_id"], name: "index_npq_contracts_on_cohort_id"
    t.index ["npq_lead_provider_id"], name: "index_npq_contracts_on_npq_lead_provider_id"
  end

  create_table "npq_courses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "identifier"
  end

  create_table "npq_lead_providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "cpd_lead_provider_id"
    t.boolean "vat_chargeable", default: true
    t.index ["cpd_lead_provider_id"], name: "index_npq_lead_providers_on_cpd_lead_provider_id"
  end

  create_table "participant_bands", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "call_off_contract_id", null: false
    t.integer "min"
    t.integer "max"
    t.decimal "per_participant"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "output_payment_percantage", default: 60
    t.integer "service_fee_percentage", default: 40
    t.index ["call_off_contract_id"], name: "index_participant_bands_on_call_off_contract_id"
  end

  create_table "participant_declaration_attempts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "declaration_type"
    t.datetime "declaration_date"
    t.uuid "user_id"
    t.string "course_identifier"
    t.string "evidence_held"
    t.uuid "cpd_lead_provider_id"
    t.uuid "participant_declaration_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["participant_declaration_id"], name: "index_declaration_attempts_on_declarations"
  end

  create_table "participant_declarations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "declaration_type"
    t.datetime "declaration_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "user_id", null: false
    t.string "course_identifier"
    t.string "evidence_held"
    t.string "type", default: "ParticipantDeclaration::ECF"
    t.uuid "cpd_lead_provider_id"
    t.string "state", default: "submitted", null: false
    t.uuid "participant_profile_id"
    t.uuid "superseded_by_id"
    t.boolean "sparsity_uplift"
    t.boolean "pupil_premium_uplift"
    t.uuid "delivery_partner_id"
    t.index ["cpd_lead_provider_id", "participant_profile_id", "declaration_type", "course_identifier", "state"], name: "unique_declaration_index", unique: true, where: "((state)::text = ANY ((ARRAY['submitted'::character varying, 'eligible'::character varying, 'payable'::character varying, 'paid'::character varying])::text[]))"
    t.index ["cpd_lead_provider_id"], name: "index_participant_declarations_on_cpd_lead_provider_id"
    t.index ["declaration_type"], name: "index_participant_declarations_on_declaration_type"
    t.index ["delivery_partner_id"], name: "index_participant_declarations_on_delivery_partner_id"
    t.index ["participant_profile_id"], name: "index_participant_declarations_on_participant_profile_id"
    t.index ["superseded_by_id"], name: "superseded_by_index"
    t.index ["user_id"], name: "index_participant_declarations_on_user_id"
  end

  create_table "participant_identities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.citext "email", null: false
    t.uuid "external_identifier", null: false
    t.string "origin", default: "ecf", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_participant_identities_on_email", unique: true
    t.index ["external_identifier"], name: "index_participant_identities_on_external_identifier", unique: true
    t.index ["user_id"], name: "index_participant_identities_on_user_id"
  end

  create_table "participant_outcome_api_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "request_path"
    t.integer "status_code"
    t.jsonb "request_headers"
    t.jsonb "request_body"
    t.jsonb "response_body"
    t.jsonb "response_headers"
    t.uuid "participant_outcome_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["participant_outcome_id"], name: "index_participant_outcome_api_requests_on_participant_outcome"
  end

  create_table "participant_outcomes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "state", null: false
    t.date "completion_date", null: false
    t.uuid "participant_declaration_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "qualified_teachers_api_request_successful"
    t.datetime "sent_to_qualified_teachers_api_at"
    t.index ["created_at"], name: "index_participant_outcomes_on_created_at"
    t.index ["participant_declaration_id"], name: "index_declaration"
    t.index ["sent_to_qualified_teachers_api_at"], name: "index_participant_outcomes_on_sent_to_qualified_teachers_api_at"
    t.index ["state"], name: "index_participant_outcomes_on_state"
  end

  create_table "participant_profile_schedules", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "participant_profile_id", null: false
    t.uuid "schedule_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["participant_profile_id"], name: "index_participant_profile_schedules_on_participant_profile_id"
    t.index ["schedule_id"], name: "index_participant_profile_schedules_on_schedule_id"
  end

  create_table "participant_profile_states", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "participant_profile_id", null: false
    t.text "state", default: "active"
    t.text "reason"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "cpd_lead_provider_id"
    t.index ["cpd_lead_provider_id"], name: "index_participant_profile_states_on_cpd_lead_provider_id"
    t.index ["participant_profile_id", "cpd_lead_provider_id"], name: "index_on_profile_and_lead_provider"
    t.index ["participant_profile_id", "state", "cpd_lead_provider_id"], name: "index_on_profile_and_state_and_lead_provider"
    t.index ["participant_profile_id"], name: "index_participant_profile_states_on_participant_profile_id"
  end

  create_table "participant_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type", null: false
    t.uuid "school_id"
    t.uuid "core_induction_programme_id"
    t.uuid "cohort_id"
    t.uuid "mentor_profile_id"
    t.boolean "sparsity_uplift", default: false, null: false
    t.boolean "pupil_premium_uplift", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "status", default: "active", null: false
    t.uuid "school_cohort_id"
    t.uuid "teacher_profile_id"
    t.uuid "schedule_id", null: false
    t.uuid "npq_course_id"
    t.text "school_urn"
    t.text "school_ukprn"
    t.datetime "request_for_details_sent_at"
    t.string "training_status", default: "active", null: false
    t.string "profile_duplicity", default: "single", null: false
    t.uuid "participant_identity_id"
    t.string "notes"
    t.date "induction_start_date"
    t.index ["cohort_id"], name: "index_participant_profiles_on_cohort_id"
    t.index ["core_induction_programme_id"], name: "index_participant_profiles_on_core_induction_programme_id"
    t.index ["mentor_profile_id"], name: "index_participant_profiles_on_mentor_profile_id"
    t.index ["npq_course_id"], name: "index_participant_profiles_on_npq_course_id"
    t.index ["participant_identity_id"], name: "index_participant_profiles_on_participant_identity_id"
    t.index ["schedule_id"], name: "index_participant_profiles_on_schedule_id"
    t.index ["school_cohort_id"], name: "index_participant_profiles_on_school_cohort_id"
    t.index ["school_id"], name: "index_participant_profiles_on_school_id"
    t.index ["teacher_profile_id"], name: "index_participant_profiles_on_teacher_profile_id"
  end

  create_table "partnership_csv_uploads", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "lead_provider_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "delivery_partner_id", null: false
    t.uuid "cohort_id"
    t.string "uploaded_urns", array: true
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
    t.boolean "relationship", default: false, null: false
    t.index ["cohort_id"], name: "index_partnerships_on_cohort_id"
    t.index ["delivery_partner_id"], name: "index_partnerships_on_delivery_partner_id"
    t.index ["lead_provider_id"], name: "index_partnerships_on_lead_provider_id"
    t.index ["pending"], name: "index_partnerships_on_pending"
    t.index ["school_id", "lead_provider_id", "delivery_partner_id", "cohort_id"], name: "unique_partnerships", unique: true
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

  create_table "profile_validation_decisions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "participant_profile_id", null: false
    t.string "validation_step", null: false
    t.boolean "approved"
    t.text "note"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["participant_profile_id", "validation_step"], name: "unique_validation_step", unique: true
    t.index ["participant_profile_id"], name: "index_profile_validation_decisions_on_participant_profile_id"
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
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "pupil_premium_incentive", default: false, null: false
    t.boolean "sparsity_incentive", default: false, null: false
    t.index ["school_id"], name: "index_pupil_premiums_on_school_id"
  end

  create_table "schedule_milestones", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.uuid "schedule_id", null: false
    t.uuid "milestone_id", null: false
    t.string "declaration_type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["milestone_id", "schedule_id", "declaration_type"], name: "milestones_schedules_schedule_milestone_declaration_type", unique: true
    t.index ["milestone_id"], name: "index_schedule_milestones_on_milestone_id"
    t.index ["schedule_id", "milestone_id", "declaration_type"], name: "schedules_milestones_schedule_milestone_declaration_type", unique: true
    t.index ["schedule_id"], name: "index_schedule_milestones_on_schedule_id"
  end

  create_table "schedules", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "schedule_identifier"
    t.string "type", default: "Finance::Schedule::ECF"
    t.uuid "cohort_id"
    t.text "identifier_alias"
    t.index ["cohort_id"], name: "index_schedules_on_cohort_id"
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
    t.uuid "default_induction_programme_id"
    t.uuid "appropriate_body_id"
    t.index ["appropriate_body_id"], name: "index_school_cohorts_on_appropriate_body_id"
    t.index ["cohort_id"], name: "index_school_cohorts_on_cohort_id"
    t.index ["core_induction_programme_id"], name: "index_school_cohorts_on_core_induction_programme_id"
    t.index ["default_induction_programme_id"], name: "index_school_cohorts_on_default_induction_programme_id"
    t.index ["school_id", "cohort_id"], name: "index_school_cohorts_on_school_id_and_cohort_id", unique: true
    t.index ["school_id"], name: "index_school_cohorts_on_school_id"
    t.index ["updated_at"], name: "index_school_cohorts_on_updated_at"
  end

  create_table "school_links", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "school_id", null: false
    t.string "link_urn", null: false
    t.string "link_type", null: false
    t.string "link_reason", default: "simple", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["school_id"], name: "index_school_links_on_school_id"
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

  create_table "school_mentors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "participant_profile_id", null: false
    t.uuid "school_id", null: false
    t.uuid "preferred_identity_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "remove_from_school_on"
    t.index ["participant_profile_id", "school_id"], name: "index_school_mentors_on_participant_profile_id_and_school_id", unique: true
    t.index ["participant_profile_id"], name: "index_school_mentors_on_participant_profile_id"
    t.index ["preferred_identity_id"], name: "index_school_mentors_on_preferred_identity_id"
    t.index ["school_id"], name: "index_school_mentors_on_school_id"
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
    t.boolean "section_41_approved", default: false, null: false
    t.index ["name"], name: "index_schools_on_name"
    t.index ["network_id"], name: "index_schools_on_network_id"
    t.index ["school_type_code", "school_status_code"], name: "index_schools_on_school_type_code_and_school_status_code"
    t.index ["section_41_approved", "school_status_code"], name: "index_schools_on_section_41_approved_and_school_status_code", where: "section_41_approved"
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

  create_table "statement_line_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "statement_id", null: false
    t.uuid "participant_declaration_id", null: false
    t.text "state", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["participant_declaration_id", "statement_id", "state"], name: "unique_declaration_statement_state", unique: true
    t.index ["statement_id", "participant_declaration_id", "state"], name: "unique_statement_declaration_state", unique: true
  end

  create_table "statements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "type", null: false
    t.text "name", null: false
    t.uuid "cpd_lead_provider_id", null: false
    t.date "deadline_date"
    t.date "payment_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "original_value"
    t.uuid "cohort_id", null: false
    t.boolean "output_fee", default: true
    t.string "contract_version", default: "0.0.1"
    t.decimal "reconcile_amount", default: "0.0", null: false
    t.index ["cohort_id"], name: "index_statements_on_cohort_id"
    t.index ["cpd_lead_provider_id"], name: "index_statements_on_cpd_lead_provider_id"
  end

  create_table "sync_dqt_induction_start_date_errors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "participant_profile_id", null: false
    t.text "message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["participant_profile_id"], name: "dqt_sync_participant_profile_id"
  end

  create_table "teacher_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "trn"
    t.uuid "school_id"
    t.uuid "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["school_id"], name: "index_teacher_profiles_on_school_id"
    t.index ["user_id"], name: "index_teacher_profiles_on_user_id", unique: true
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
    t.string "get_an_identity_id"
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["get_an_identity_id"], name: "index_users_on_get_an_identity_id", unique: true
  end

  create_table "versions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "item_type"
    t.string "{:null=>false}"
    t.string "event", null: false
    t.string "whodunnit"
    t.json "object"
    t.json "object_changes"
    t.datetime "created_at"
    t.uuid "item_id", default: -> { "gen_random_uuid()" }, null: false
    t.string "reason"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "additional_school_emails", "schools"
  add_foreign_key "admin_profiles", "users"
  add_foreign_key "api_requests", "cpd_lead_providers"
  add_foreign_key "api_tokens", "cpd_lead_providers"
  add_foreign_key "api_tokens", "lead_providers", on_delete: :cascade
  add_foreign_key "appropriate_body_profiles", "appropriate_bodies"
  add_foreign_key "appropriate_body_profiles", "users"
  add_foreign_key "call_off_contracts", "lead_providers"
  add_foreign_key "cohorts_lead_providers", "cohorts"
  add_foreign_key "cohorts_lead_providers", "lead_providers"
  add_foreign_key "data_stage_school_changes", "data_stage_schools"
  add_foreign_key "data_stage_school_links", "data_stage_schools"
  add_foreign_key "deleted_duplicates", "participant_profiles", column: "primary_participant_profile_id"
  add_foreign_key "delivery_partner_profiles", "delivery_partners"
  add_foreign_key "delivery_partner_profiles", "users"
  add_foreign_key "district_sparsities", "local_authority_districts"
  add_foreign_key "ecf_participant_eligibilities", "participant_profiles"
  add_foreign_key "ecf_participant_validation_data", "participant_profiles"
  add_foreign_key "email_associations", "emails"
  add_foreign_key "feature_selected_objects", "features"
  add_foreign_key "finance_profiles", "users"
  add_foreign_key "induction_coordinator_profiles", "users"
  add_foreign_key "induction_programmes", "core_induction_programmes"
  add_foreign_key "induction_programmes", "partnerships"
  add_foreign_key "induction_programmes", "school_cohorts"
  add_foreign_key "induction_records", "induction_programmes"
  add_foreign_key "induction_records", "participant_profiles"
  add_foreign_key "induction_records", "schedules"
  add_foreign_key "lead_provider_cips", "cohorts"
  add_foreign_key "lead_provider_cips", "core_induction_programmes"
  add_foreign_key "lead_provider_cips", "lead_providers"
  add_foreign_key "lead_provider_profiles", "lead_providers"
  add_foreign_key "lead_provider_profiles", "users"
  add_foreign_key "lead_providers", "cpd_lead_providers"
  add_foreign_key "milestones", "schedules"
  add_foreign_key "nomination_emails", "partnership_notification_emails"
  add_foreign_key "nomination_emails", "schools"
  add_foreign_key "npq_application_eligibility_imports", "users"
  add_foreign_key "npq_application_exports", "users"
  add_foreign_key "npq_applications", "npq_courses"
  add_foreign_key "npq_applications", "npq_lead_providers"
  add_foreign_key "npq_applications", "participant_identities"
  add_foreign_key "npq_lead_providers", "cpd_lead_providers"
  add_foreign_key "participant_bands", "call_off_contracts"
  add_foreign_key "participant_declaration_attempts", "participant_declarations"
  add_foreign_key "participant_declarations", "participant_declarations", column: "superseded_by_id"
  add_foreign_key "participant_declarations", "participant_profiles"
  add_foreign_key "participant_declarations", "users"
  add_foreign_key "participant_identities", "users"
  add_foreign_key "participant_outcome_api_requests", "participant_outcomes"
  add_foreign_key "participant_outcomes", "participant_declarations"
  add_foreign_key "participant_profile_schedules", "participant_profiles"
  add_foreign_key "participant_profile_schedules", "schedules"
  add_foreign_key "participant_profile_states", "participant_profiles"
  add_foreign_key "participant_profiles", "cohorts"
  add_foreign_key "participant_profiles", "core_induction_programmes"
  add_foreign_key "participant_profiles", "npq_courses"
  add_foreign_key "participant_profiles", "participant_identities"
  add_foreign_key "participant_profiles", "participant_profiles", column: "mentor_profile_id"
  add_foreign_key "participant_profiles", "schedules"
  add_foreign_key "participant_profiles", "school_cohorts"
  add_foreign_key "participant_profiles", "schools"
  add_foreign_key "participant_profiles", "teacher_profiles"
  add_foreign_key "partnership_notification_emails", "partnerships"
  add_foreign_key "partnerships", "cohorts"
  add_foreign_key "partnerships", "delivery_partners"
  add_foreign_key "partnerships", "lead_providers"
  add_foreign_key "partnerships", "schools"
  add_foreign_key "profile_validation_decisions", "participant_profiles"
  add_foreign_key "provider_relationships", "cohorts"
  add_foreign_key "provider_relationships", "delivery_partners"
  add_foreign_key "provider_relationships", "lead_providers"
  add_foreign_key "pupil_premiums", "schools"
  add_foreign_key "schedule_milestones", "milestones"
  add_foreign_key "schedule_milestones", "schedules"
  add_foreign_key "schedules", "cohorts"
  add_foreign_key "school_cohorts", "cohorts"
  add_foreign_key "school_cohorts", "core_induction_programmes"
  add_foreign_key "school_cohorts", "induction_programmes", column: "default_induction_programme_id"
  add_foreign_key "school_cohorts", "schools"
  add_foreign_key "school_local_authorities", "local_authorities"
  add_foreign_key "school_local_authorities", "schools"
  add_foreign_key "school_local_authority_districts", "local_authority_districts"
  add_foreign_key "school_local_authority_districts", "schools"
  add_foreign_key "school_mentors", "participant_identities", column: "preferred_identity_id"
  add_foreign_key "school_mentors", "participant_profiles"
  add_foreign_key "school_mentors", "schools"
  add_foreign_key "schools", "networks"
  add_foreign_key "sync_dqt_induction_start_date_errors", "participant_profiles"
  add_foreign_key "teacher_profiles", "schools"
  add_foreign_key "teacher_profiles", "users"

  create_view "ecf_duplicates", sql_definition: <<-SQL
      SELECT participant_identities.user_id,
      participant_identities.external_identifier,
      participant_profiles.id,
      participant_profiles.created_at,
      participant_profiles.updated_at,
      first_value(participant_profiles.id) OVER (PARTITION BY participant_identities.user_id ORDER BY
          CASE
              WHEN (((latest_induction_records.training_status)::text = 'active'::text) AND ((latest_induction_records.induction_status)::text = 'active'::text)) THEN 1
              WHEN (((latest_induction_records.training_status)::text = 'active'::text) AND ((latest_induction_records.induction_status)::text <> 'active'::text)) THEN 2
              WHEN (((latest_induction_records.training_status)::text <> 'active'::text) AND ((latest_induction_records.induction_status)::text = 'active'::text)) THEN 3
              ELSE 4
          END, COALESCE(declarations.count, (0)::bigint) DESC, participant_profiles.created_at DESC) AS primary_participant_profile_id,
          CASE participant_profiles.type
              WHEN 'ParticipantProfile::Mentor'::text THEN 'mentor'::text
              ELSE 'ect'::text
          END AS profile_type,
      duplicates.count AS duplicate_profile_count,
      latest_induction_records.id AS latest_induction_record_id,
      latest_induction_records.induction_status,
      latest_induction_records.training_status,
      latest_induction_records.start_date,
      latest_induction_records.end_date,
      latest_induction_records.school_transfer,
      latest_induction_records.school_id,
      latest_induction_records.school_name,
      latest_induction_records.lead_provider_name AS provider_name,
      latest_induction_records.training_programme,
      schedules.schedule_identifier,
      cohorts.start_year AS cohort,
      teacher_profiles.trn AS teacher_profile_trn,
      teacher_profiles.id AS teacher_profile_id,
      COALESCE(declarations.count, (0)::bigint) AS declaration_count,
      row_number() OVER (PARTITION BY participant_identities.user_id ORDER BY
          CASE
              WHEN (((latest_induction_records.training_status)::text = 'active'::text) AND ((latest_induction_records.induction_status)::text = 'active'::text)) THEN 1
              WHEN (((latest_induction_records.training_status)::text = 'active'::text) AND ((latest_induction_records.induction_status)::text <> 'active'::text)) THEN 2
              WHEN (((latest_induction_records.training_status)::text <> 'active'::text) AND ((latest_induction_records.induction_status)::text = 'active'::text)) THEN 3
              ELSE 4
          END) AS participant_profile_status
     FROM (((((((participant_profiles
       LEFT JOIN ( SELECT induction_records.id,
              induction_records.induction_programme_id,
              induction_records.participant_profile_id,
              induction_records.schedule_id,
              induction_records.start_date,
              induction_records.end_date,
              induction_records.created_at,
              induction_records.updated_at,
              induction_records.training_status,
              induction_records.preferred_identity_id,
              induction_records.induction_status,
              induction_records.mentor_profile_id,
              induction_records.school_transfer,
              induction_records.appropriate_body_id,
              partnerships.lead_provider_id,
              schools.id AS school_id,
              schools.name AS school_name,
              lead_providers.name AS lead_provider_name,
              induction_programmes.training_programme,
              row_number() OVER (PARTITION BY induction_records.participant_profile_id ORDER BY induction_records.created_at DESC) AS induction_record_sort_order
             FROM ((((induction_records
               JOIN induction_programmes ON ((induction_programmes.id = induction_records.induction_programme_id)))
               LEFT JOIN partnerships ON ((partnerships.id = induction_programmes.partnership_id)))
               LEFT JOIN lead_providers ON ((lead_providers.id = partnerships.lead_provider_id)))
               LEFT JOIN schools ON ((schools.id = partnerships.school_id)))) latest_induction_records ON (((latest_induction_records.participant_profile_id = participant_profiles.id) AND (latest_induction_records.induction_record_sort_order = 1))))
       JOIN participant_identities ON ((participant_identities.id = participant_profiles.participant_identity_id)))
       JOIN ( SELECT participant_identities_1.user_id,
              count(*) AS count
             FROM (participant_profiles participant_profiles_1
               JOIN participant_identities participant_identities_1 ON ((participant_identities_1.id = participant_profiles_1.participant_identity_id)))
            WHERE ((participant_profiles_1.type)::text = ANY ((ARRAY['ParticipantProfile::ECT'::character varying, 'ParticipantProfile::Mentor'::character varying])::text[]))
            GROUP BY participant_profiles_1.type, participant_identities_1.user_id) duplicates ON ((duplicates.user_id = participant_identities.user_id)))
       LEFT JOIN teacher_profiles ON ((teacher_profiles.id = participant_profiles.teacher_profile_id)))
       LEFT JOIN schedules ON ((latest_induction_records.schedule_id = schedules.id)))
       LEFT JOIN cohorts ON ((schedules.cohort_id = cohorts.id)))
       LEFT JOIN ( SELECT participant_declarations.participant_profile_id,
              count(*) AS count
             FROM participant_declarations
            GROUP BY participant_declarations.participant_profile_id) declarations ON ((participant_profiles.id = declarations.participant_profile_id)))
    WHERE ((participant_identities.user_id IN ( SELECT participant_identities_1.user_id
             FROM (participant_profiles participant_profiles_1
               JOIN participant_identities participant_identities_1 ON ((participant_identities_1.id = participant_profiles_1.participant_identity_id)))
            WHERE ((participant_profiles_1.type)::text = ANY ((ARRAY['ParticipantProfile::ECT'::character varying, 'ParticipantProfile::Mentor'::character varying])::text[]))
            GROUP BY participant_profiles_1.type, participant_identities_1.user_id
           HAVING (count(*) > 1))) AND ((participant_profiles.type)::text = ANY ((ARRAY['ParticipantProfile::ECT'::character varying, 'ParticipantProfile::Mentor'::character varying])::text[])))
    ORDER BY participant_identities.external_identifier, (row_number() OVER (PARTITION BY participant_identities.user_id ORDER BY
          CASE
              WHEN (((latest_induction_records.training_status)::text = 'active'::text) AND ((latest_induction_records.induction_status)::text = 'active'::text)) THEN 1
              WHEN (((latest_induction_records.training_status)::text = 'active'::text) AND ((latest_induction_records.induction_status)::text <> 'active'::text)) THEN 2
              WHEN (((latest_induction_records.training_status)::text <> 'active'::text) AND ((latest_induction_records.induction_status)::text = 'active'::text)) THEN 3
              ELSE 4
          END)), participant_profiles.created_at DESC;
  SQL
  create_view "training_record_states", materialized: true, sql_definition: <<-SQL
      WITH mentee_counts AS (
           SELECT induction_records.mentor_profile_id,
              count(*) AS total
             FROM induction_records
            GROUP BY induction_records.mentor_profile_id, induction_records.participant_profile_id
          ), individual_training_record_states AS (
           SELECT participant_profiles.id AS participant_profile_id,
              induction_records.id AS induction_record_id,
                  CASE
                      WHEN (partnerships.school_id IS NOT NULL) THEN partnerships.school_id
                      ELSE school_cohorts.school_id
                  END AS school_id,
              partnerships.lead_provider_id,
              partnerships.delivery_partner_id,
              induction_programmes.training_programme,
              GREATEST(induction_records.start_date, participant_profiles.updated_at, ecf_participant_eligibilities.updated_at, ecf_participant_validation_data.updated_at, teacher_profiles.updated_at, emails.updated_at) AS changed_at,
                  CASE
                      WHEN (((ecf_participant_eligibilities.status)::text = 'manual_check'::text) AND ((ecf_participant_eligibilities.reason)::text = 'different_trn'::text)) THEN 'different_trn'::text
                      WHEN ((teacher_profiles.trn IS NULL) AND (ecf_participant_validation_data.* IS NULL)) THEN
                      CASE
                          WHEN ((emails.status)::text = 'delivered'::text) THEN 'request_for_details_delivered'::text
                          WHEN ((emails.status)::text = ANY ((ARRAY['permanent-failure'::character varying, 'technical-failure'::character varying, 'temporary-failure'::character varying])::text[])) THEN 'request_for_details_failed'::text
                          WHEN ((emails.status)::text = 'submitted'::text) THEN 'request_for_details_submitted'::text
                          ELSE 'validation_not_started'::text
                      END
                      WHEN (ecf_participant_validation_data.api_failure = true) THEN 'internal_error'::text
                      WHEN (teacher_profiles.trn IS NULL) THEN 'tra_record_not_found'::text
                      ELSE 'valid'::text
                  END AS validation_state,
                  CASE
                      WHEN ((((participant_profiles.type)::text = 'ParticipantProfile::ECT'::text) AND (ecf_participant_eligibilities.* IS NULL)) OR ((teacher_profiles.trn IS NOT NULL) AND (ecf_participant_eligibilities.* IS NULL))) THEN 'checks_not_complete'::text
                      WHEN (((ecf_participant_eligibilities.status)::text = 'manual_check'::text) AND ((ecf_participant_eligibilities.reason)::text = 'active_flags'::text)) THEN 'active_flags'::text
                      WHEN (((ecf_participant_eligibilities.status)::text = 'ineligible'::text) AND ((ecf_participant_eligibilities.reason)::text = 'active_flags'::text)) THEN 'not_allowed'::text
                      WHEN ((participant_profiles.type)::text = 'ParticipantProfile::Mentor'::text) THEN
                      CASE
                          WHEN ((mentee_counts.total > 0) AND ((induction_programmes.training_programme)::text = 'full_induction_programme'::text) AND (partnerships.lead_provider_id IS NULL)) THEN 'eligible_for_mentor_training_no_partner'::text
                          WHEN (mentee_counts.total > 0) THEN 'eligible_for_mentor_training'::text
                          ELSE 'not_yet_mentoring'::text
                      END
                      WHEN (((ecf_participant_eligibilities.status)::text = 'ineligible'::text) AND ((ecf_participant_eligibilities.reason)::text = 'duplicate_profile'::text)) THEN 'duplicate_profile'::text
                      WHEN (((ecf_participant_eligibilities.status)::text = 'manual_check'::text) AND ((ecf_participant_eligibilities.reason)::text = 'no_qts'::text)) THEN 'not_qualified'::text
                      WHEN (((ecf_participant_eligibilities.status)::text = 'ineligible'::text) AND ((ecf_participant_eligibilities.reason)::text = 'exempt_from_induction'::text)) THEN 'exempt_from_induction'::text
                      WHEN (((ecf_participant_eligibilities.status)::text = 'ineligible'::text) AND ((ecf_participant_eligibilities.reason)::text = 'previous_induction'::text)) THEN 'previous_induction'::text
                      WHEN ((((participant_profiles.type)::text = 'ParticipantProfile::Mentor'::text) AND (ecf_participant_validation_data.trn IS NOT NULL) AND (teacher_profiles.trn IS NULL)) OR (((participant_profiles.type)::text = 'ParticipantProfile::ECT'::text) AND (teacher_profiles.trn IS NULL))) THEN 'tra_record_not_found'::text
                      WHEN (((induction_programmes.training_programme)::text = 'full_induction_programme'::text) AND (partnerships.lead_provider_id IS NULL)) THEN 'eligible_for_induction_training_no_partner'::text
                      ELSE 'eligible_for_induction_training'::text
                  END AS training_eligibility_state,
                  CASE
                      WHEN ((((participant_profiles.type)::text = 'ParticipantProfile::ECT'::text) AND (ecf_participant_eligibilities.* IS NULL)) OR ((teacher_profiles.trn IS NOT NULL) AND (ecf_participant_eligibilities.* IS NULL))) THEN 'checks_not_complete'::text
                      WHEN (((participant_profiles.type)::text = 'ParticipantProfile::ECT'::text) AND ((ecf_participant_eligibilities.status)::text = 'eligible'::text)) THEN 'eligible_for_fip_funding'::text
                      WHEN (((ecf_participant_eligibilities.status)::text = 'manual_check'::text) AND ((ecf_participant_eligibilities.reason)::text = 'active_flags'::text)) THEN 'active_flags'::text
                      WHEN (((ecf_participant_eligibilities.status)::text = 'ineligible'::text) AND ((ecf_participant_eligibilities.reason)::text = 'active_flags'::text)) THEN 'not_allowed'::text
                      WHEN (((participant_profiles.type)::text = 'ParticipantProfile::Mentor'::text) AND ((ecf_participant_eligibilities.status)::text = 'ineligible'::text) AND ((ecf_participant_eligibilities.reason)::text = 'previous_participation'::text)) THEN
                      CASE
                          WHEN ((participant_profiles.profile_duplicity)::text = 'secondary'::text) THEN 'ineligible_ero_secondary'::text
                          WHEN ((participant_profiles.profile_duplicity)::text = 'primary'::text) THEN 'ineligible_ero_primary'::text
                          WHEN ((ecf_participant_eligibilities.reason)::text = 'duplicate_profile'::text) THEN 'ineligible_ero_secondary'::text
                          ELSE 'ineligible_ero'::text
                      END
                      WHEN ((participant_profiles.type)::text = 'ParticipantProfile::Mentor'::text) THEN
                      CASE
                          WHEN ((participant_profiles.profile_duplicity)::text = 'secondary'::text) THEN 'ineligible_secondary'::text
                          WHEN ((participant_profiles.profile_duplicity)::text = 'primary'::text) THEN 'eligible_for_mentor_funding_primary'::text
                          WHEN (((ecf_participant_eligibilities.status)::text = 'ineligible'::text) AND ((ecf_participant_eligibilities.reason)::text = 'duplicate_profile'::text)) THEN 'ineligible_secondary'::text
                          ELSE 'eligible_for_mentor_funding'::text
                      END
                      WHEN (((ecf_participant_eligibilities.status)::text = 'manual_check'::text) AND ((ecf_participant_eligibilities.reason)::text = 'no_induction'::text)) THEN 'no_induction_start'::text
                      WHEN (((ecf_participant_eligibilities.status)::text = 'manual_check'::text) AND ((ecf_participant_eligibilities.reason)::text = 'no_qts'::text)) THEN 'not_qualified'::text
                      WHEN (((ecf_participant_eligibilities.status)::text = 'ineligible'::text) AND ((ecf_participant_eligibilities.reason)::text = 'duplicate_profile'::text)) THEN 'duplicate_profile'::text
                      WHEN (((ecf_participant_eligibilities.status)::text = 'ineligible'::text) AND ((ecf_participant_eligibilities.reason)::text = 'exempt_from_induction'::text)) THEN 'exempt_from_induction'::text
                      WHEN (((ecf_participant_eligibilities.status)::text = 'ineligible'::text) AND ((ecf_participant_eligibilities.reason)::text = 'previous_induction'::text)) THEN 'previous_induction'::text
                      WHEN ((((participant_profiles.type)::text = 'ParticipantProfile::Mentor'::text) AND (ecf_participant_validation_data.trn IS NOT NULL) AND (teacher_profiles.trn IS NULL)) OR (((participant_profiles.type)::text = 'ParticipantProfile::ECT'::text) AND (teacher_profiles.trn IS NULL))) THEN 'tra_record_not_found'::text
                      ELSE 'eligible_for_fip_funding'::text
                  END AS fip_funding_eligibility_state,
                  CASE
                      WHEN (((induction_records.induction_status)::text = 'withdrawn'::text) OR ((induction_records.* IS NULL) AND (participant_profiles.status = 'withdrawn'::text))) THEN 'withdrawn_programme'::text
                      WHEN (((induction_records.training_status)::text = 'withdrawn'::text) OR ((induction_records.* IS NULL) AND ((participant_profiles.training_status)::text = 'withdrawn'::text))) THEN 'withdrawn_training'::text
                      WHEN (((induction_records.training_status)::text = 'deferred'::text) OR ((induction_records.* IS NULL) AND ((participant_profiles.training_status)::text = 'deferred'::text))) THEN 'deferred_training'::text
                      WHEN (((induction_records.induction_status)::text = 'completed'::text) OR ((induction_records.* IS NULL) AND (participant_profiles.status = 'completed'::text))) THEN 'completed_training'::text
                      WHEN ((induction_records.induction_status)::text = 'changed'::text) THEN 'no_longer_involved'::text
                      WHEN (((induction_records.induction_status)::text = 'leaving'::text) AND (induction_records.end_date >= CURRENT_DATE)) THEN 'leaving'::text
                      WHEN (((induction_records.induction_status)::text = 'leaving'::text) AND (induction_records.end_date < CURRENT_DATE)) THEN 'left'::text
                      WHEN (((induction_records.induction_status)::text = 'active'::text) AND (induction_records.start_date > CURRENT_DATE)) THEN 'joining'::text
                      WHEN ((participant_profiles.type)::text = 'ParticipantProfile::Mentor'::text) THEN
                      CASE
                          WHEN ((induction_programmes.training_programme)::text = 'full_induction_programme'::text) THEN
                          CASE
                              WHEN ((mentee_counts.total > 0) AND (partnerships.lead_provider_id IS NULL)) THEN 'active_fip_mentoring_no_partner'::text
                              WHEN ((mentee_counts.total > 0) AND ((ecf_participant_eligibilities.reason)::text = 'previous_participation'::text)) THEN 'active_fip_mentoring_ero'::text
                              WHEN (mentee_counts.total > 0) THEN 'active_fip_mentoring'::text
                              WHEN (partnerships.lead_provider_id IS NULL) THEN 'not_yet_mentoring_fip_no_partner'::text
                              WHEN ((ecf_participant_eligibilities.reason)::text = 'previous_participation'::text) THEN 'not_yet_mentoring_fip_ero'::text
                              ELSE 'not_yet_mentoring_fip'::text
                          END
                          ELSE
                          CASE
                              WHEN ((mentee_counts.total > 0) AND ((ecf_participant_eligibilities.reason)::text = 'previous_participation'::text)) THEN 'active_cip_mentoring_ero'::text
                              WHEN (mentee_counts.total > 0) THEN 'active_cip_mentoring'::text
                              WHEN ((ecf_participant_eligibilities.reason)::text = 'previous_participation'::text) THEN 'not_yet_mentoring_cip_ero'::text
                              ELSE 'not_yet_mentoring_cip'::text
                          END
                      END
                      ELSE
                      CASE
                          WHEN (((induction_programmes.training_programme)::text = 'full_induction_programme'::text) AND (partnerships.lead_provider_id IS NULL)) THEN 'registered_for_fip_no_partner'::text
                          WHEN (((induction_programmes.training_programme)::text = 'full_induction_programme'::text) AND ((ecf_participant_eligibilities.status)::text = 'manual_check'::text) AND ((ecf_participant_eligibilities.reason)::text = 'no_induction'::text)) THEN 'registered_for_fip_training'::text
                          WHEN ((induction_programmes.training_programme)::text = 'full_induction_programme'::text) THEN 'active_fip_training'::text
                          WHEN (((induction_programmes.training_programme)::text = 'core_induction_programme'::text) AND ((ecf_participant_eligibilities.status)::text = 'manual_check'::text) AND ((ecf_participant_eligibilities.reason)::text = 'no_induction'::text)) THEN 'registered_for_cip_training'::text
                          WHEN ((induction_programmes.training_programme)::text = 'core_induction_programme'::text) THEN 'active_cip_training'::text
                          ELSE 'active_diy_training'::text
                      END
                  END AS training_state
             FROM (((((((((((participant_profiles
               LEFT JOIN induction_records ON ((induction_records.participant_profile_id = participant_profiles.id)))
               LEFT JOIN induction_programmes ON ((induction_programmes.id = induction_records.induction_programme_id)))
               LEFT JOIN appropriate_bodies ON ((appropriate_bodies.id = induction_records.appropriate_body_id)))
               LEFT JOIN partnerships ON ((partnerships.id = induction_programmes.partnership_id)))
               LEFT JOIN school_cohorts ON ((school_cohorts.id = induction_programmes.school_cohort_id)))
               LEFT JOIN ecf_participant_validation_data ON ((ecf_participant_validation_data.participant_profile_id = participant_profiles.id)))
               LEFT JOIN ecf_participant_eligibilities ON ((ecf_participant_eligibilities.participant_profile_id = participant_profiles.id)))
               LEFT JOIN teacher_profiles ON ((teacher_profiles.id = participant_profiles.teacher_profile_id)))
               LEFT JOIN email_associations ON (((email_associations.object_id = participant_profiles.id) AND ((email_associations.object_type)::text = 'ParticipantProfile'::text))))
               LEFT JOIN emails ON (((emails.id = email_associations.email_id) AND ('request_for_details'::text = ANY ((emails.tags)::text[])))))
               LEFT JOIN mentee_counts ON ((mentee_counts.mentor_profile_id = participant_profiles.id)))
          )
   SELECT individual_training_record_states.participant_profile_id,
      individual_training_record_states.induction_record_id,
      individual_training_record_states.school_id,
      individual_training_record_states.lead_provider_id,
      individual_training_record_states.delivery_partner_id,
      min(individual_training_record_states.changed_at) AS changed_at,
      individual_training_record_states.validation_state,
      individual_training_record_states.training_eligibility_state,
      individual_training_record_states.fip_funding_eligibility_state,
      individual_training_record_states.training_state,
          CASE
              WHEN (individual_training_record_states.training_state = ANY (ARRAY['withdrawn_programme'::text, 'withdrawn_training'::text, 'deferred_training'::text, 'completed_training'::text, 'leaving'::text, 'left'::text])) THEN individual_training_record_states.training_state
              WHEN (individual_training_record_states.validation_state <> 'valid'::text) THEN individual_training_record_states.validation_state
              WHEN (NOT (individual_training_record_states.training_eligibility_state = ANY (ARRAY['eligible_for_mentor_training'::text, 'eligible_for_mentor_training_no_partner'::text, 'eligible_for_induction_training'::text, 'eligible_for_induction_training_no_partner'::text, 'not_yet_mentoring'::text]))) THEN individual_training_record_states.training_eligibility_state
              WHEN (((individual_training_record_states.training_programme)::text = 'full_induction_programme'::text) AND (NOT (individual_training_record_states.fip_funding_eligibility_state = ANY (ARRAY['eligible_for_mentor_funding'::text, 'eligible_for_mentor_funding_primary'::text, 'eligible_for_fip_funding'::text])))) THEN individual_training_record_states.fip_funding_eligibility_state
              ELSE individual_training_record_states.training_state
          END AS record_state
     FROM individual_training_record_states
    GROUP BY individual_training_record_states.participant_profile_id, individual_training_record_states.induction_record_id, individual_training_record_states.school_id, individual_training_record_states.lead_provider_id, individual_training_record_states.delivery_partner_id, individual_training_record_states.validation_state, individual_training_record_states.training_eligibility_state, individual_training_record_states.fip_funding_eligibility_state, individual_training_record_states.training_state,
          CASE
              WHEN (individual_training_record_states.training_state = ANY (ARRAY['withdrawn_programme'::text, 'withdrawn_training'::text, 'deferred_training'::text, 'completed_training'::text, 'leaving'::text, 'left'::text])) THEN individual_training_record_states.training_state
              WHEN (individual_training_record_states.validation_state <> 'valid'::text) THEN individual_training_record_states.validation_state
              WHEN (NOT (individual_training_record_states.training_eligibility_state = ANY (ARRAY['eligible_for_mentor_training'::text, 'eligible_for_mentor_training_no_partner'::text, 'eligible_for_induction_training'::text, 'eligible_for_induction_training_no_partner'::text, 'not_yet_mentoring'::text]))) THEN individual_training_record_states.training_eligibility_state
              WHEN (((individual_training_record_states.training_programme)::text = 'full_induction_programme'::text) AND (NOT (individual_training_record_states.fip_funding_eligibility_state = ANY (ARRAY['eligible_for_mentor_funding'::text, 'eligible_for_mentor_funding_primary'::text, 'eligible_for_fip_funding'::text])))) THEN individual_training_record_states.fip_funding_eligibility_state
              ELSE individual_training_record_states.training_state
          END;
  SQL
end
