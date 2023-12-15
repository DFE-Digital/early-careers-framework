# frozen_string_literal: true

class RenameAnalyticsTables < ActiveRecord::Migration[7.0]
  def change
    StrongMigrations.disable_check(:rename_table)
    rename_table("ecf_appropriate_bodies", "analytics_appropriate_bodies")
    rename_table("ecf_inductions", "analytics_inductions")
    rename_table("ecf_participants", "analytics_participants")
    rename_table("ecf_partnerships", "analytics_partnerships")
    rename_table("ecf_school_cohorts", "analytics_school_cohorts")
    StrongMigrations.enable_check(:rename_table)
  end
end
