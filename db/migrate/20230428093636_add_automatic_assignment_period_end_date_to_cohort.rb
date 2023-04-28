# frozen_string_literal: true

class AddAutomaticAssignmentPeriodEndDateToCohort < ActiveRecord::Migration[6.1]
  def change
    add_column :cohorts, :automatic_assignment_period_end_date, :date
  end
end
