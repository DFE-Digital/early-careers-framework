# frozen_string_literal: true

class DropNPQProfiles < ActiveRecord::Migration[6.1]
  def change
    drop_table :npq_profiles do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :npq_lead_provider, null: false, foreign_key: true, type: :uuid
      t.references :npq_course, null: false, foreign_key: true, type: :uuid

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

      t.timestamps
    end
  end
end
