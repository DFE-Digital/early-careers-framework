# frozen_string_literal: true

class CreatePartnershipRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :partnership_requests do |t|
      t.references :lead_provider, null: false, foreign_key: true, type: :uuid
      t.references :delivery_partner, null: false, foreign_key: true, type: :uuid
      t.references :school, null: false, foreign_key: true, type: :uuid
      t.references :cohort, null: false, foreign_key: true, type: :uuid
      t.datetime :challenge_deadline

      t.timestamps
    end
  end
end
