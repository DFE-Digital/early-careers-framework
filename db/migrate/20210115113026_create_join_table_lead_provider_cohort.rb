# frozen_string_literal: true

class CreateJoinTableLeadProviderCohort < ActiveRecord::Migration[6.1]
  def change
    create_join_table :lead_providers, :cohorts, column_options: { type: :uuid, null: false, foreign_key: true } do |t|
      t.timestamps null: false
      t.index %i[lead_provider_id cohort_id]
      t.index %i[cohort_id lead_provider_id]
    end
  end
end
