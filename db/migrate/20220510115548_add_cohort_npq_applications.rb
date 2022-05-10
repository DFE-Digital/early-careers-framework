# frozen_string_literal: true

class AddCohortNPQApplications < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_reference :npq_applications, :cohort, null: true
    end
  end
end
