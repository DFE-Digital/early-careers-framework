# frozen_string_literal: true

class AddDetailedEvidenceTypesToCohort < ActiveRecord::Migration[7.1]
  def change
    add_column :cohorts, :detailed_evidence_types, :boolean, null: false, default: false
  end
end
