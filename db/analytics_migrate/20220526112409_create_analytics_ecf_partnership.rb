class CreateAnalyticsECFPartnership < ActiveRecord::Migration[6.1]
  def change
    create_table :ecf_partnership_analytics do |t|
      t.uuid :school_id
      t.string :school_name
      t.string :school_urn

      t.uuid :lead_provider_id
      t.string :lead_provider_name

      t.uuid :cohort_id
      t.string :cohort

      t.uuid :delivery_partner_id
      t.string :delivery_partner_name

      t.datetime :challenged_at
      t.string :challenge_reason
      t.datetime :challenge_deadline

      t.boolean :pending

      t.uuid :report_id

      t.boolean :relationship

      t.timestamps
    end
  end
end
