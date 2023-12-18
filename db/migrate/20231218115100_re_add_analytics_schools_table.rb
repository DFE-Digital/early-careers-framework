# frozen_string_literal: true

class ReAddAnalyticsSchoolsTable < ActiveRecord::Migration[7.0]
  def change
    create_table "analytics_schools", id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string "name"
      t.string "urn", null: false, index: { unique: true }
      t.datetime "nomination_email_opened_at", precision: nil
      t.boolean "induction_tutor_nominated"
      t.datetime "tutor_nominated_time", precision: nil
      t.boolean "induction_tutor_signed_in"
      t.string "induction_programme_choice"
      t.boolean "in_partnership"
      t.datetime "partnership_time", precision: nil
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
    end
  end
end
