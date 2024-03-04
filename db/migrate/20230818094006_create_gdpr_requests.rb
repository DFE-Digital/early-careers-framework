# frozen_string_literal: true

# noinspection RubyClassModuleNamingConvention
class CreateGDPRRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :gdpr_requests do |t|
      t.references :cpd_lead_provider, null: false, foreign_key: true
      t.references :teacher_profile, null: false, foreign_key: true
      t.string :reason, null: false

      t.timestamps
    end
  end
end
