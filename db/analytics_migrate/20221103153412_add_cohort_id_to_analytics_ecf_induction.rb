# frozen_string_literal: true

class AddCohortIdToAnalyticsECFInduction < ActiveRecord::Migration[6.1]
  def change
    add_column :ecf_inductions, :cohort_id, :uuid
  end
end
