# frozen_string_literal: true

class AddPrimaryKeyToCohortsLeadProviders < ActiveRecord::Migration[7.0]
  def change
    StrongMigrations.disable_check(:add_column_auto_incrementing)
    add_column :cohorts_lead_providers, :id, :primary_key
    StrongMigrations.enable_check(:add_column_auto_incrementing)
  end
end
