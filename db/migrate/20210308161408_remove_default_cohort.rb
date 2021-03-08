# frozen_string_literal: true

class RemoveDefaultCohort < ActiveRecord::Migration[6.1]
  def change
    change_column_default(:partnerships, :cohort_id, from: Cohort.find_or_create_by!(start_year: 2021).id, to: nil)
  end
end
