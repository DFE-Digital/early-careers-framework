# frozen_string_literal: true

class DropTableNPQApplications < ActiveRecord::Migration[7.1]
  def up
    drop_table :npq_applications
  end

  def down
    create_table :npq_applications, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.uuid :npq_lead_provider_id, null: false
      t.uuid :npq_course_id, null: false
      t.date :date_of_birth
      t.text :teacher_reference_number
      t.boolean :teacher_reference_number_verified, default: false
      t.text :school_urn
      t.text :headteacher_status
      t.boolean :active_alert, default: false
      t.boolean :eligible_for_funding, default: false, null: false
      t.text :funding_choice
      t.text :nino
      t.text :lead_provider_approval_status, default: "pending", null: false
      t.text :school_ukprn
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.uuid :participant_identity_id
      t.boolean :works_in_school
      t.string :employer_name
      t.string :employment_role
      t.boolean :targeted_support_funding_eligibility, default: false
      t.uuid :cohort_id
      t.boolean :targeted_delivery_funding_eligibility, default: false
      t.boolean :works_in_nursery
      t.boolean :works_in_childcare
      t.string :kind_of_nursery
      t.string :private_childcare_provider_urn
      t.string :funding_eligiblity_status_code
      t.text :teacher_catchment
      t.text :teacher_catchment_country
      t.string :employment_type
      t.string :teacher_catchment_iso_country_code, limit: 3
      t.string :itt_provider
      t.boolean :lead_mentor, default: false
      t.string :notes
      t.boolean :primary_establishment, default: false
      t.integer :number_of_pupils, default: 0
      t.boolean :tsf_primary_eligibility, default: false
      t.boolean :tsf_primary_plus_eligibility, default: false
      t.uuid :eligible_for_funding_updated_by_id
      t.datetime :eligible_for_funding_updated_at
      t.boolean :funded_place
      t.string :referred_by_return_to_teaching_adviser

      t.index :cohort_id, name: "index_npq_applications_on_cohort_id"
      t.index :npq_course_id, name: "index_npq_applications_on_npq_course_id"
      t.index :npq_lead_provider_id, name: "index_npq_applications_on_npq_lead_provider_id"
      t.index :participant_identity_id, name: "index_npq_applications_on_participant_identity_id"
    end
  end
end
