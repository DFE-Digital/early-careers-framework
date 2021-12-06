# frozen_string_literal: true

class AddCohortToSchedule < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_reference :schedules, :cohort, foreign_key: true
    end
  end
end
