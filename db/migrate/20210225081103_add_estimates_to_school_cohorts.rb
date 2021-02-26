# frozen_string_literal: true

class AddEstimatesToSchoolCohorts < ActiveRecord::Migration[6.1]
  def change
    change_table :school_cohorts, bulk: true do |t|
      t.integer :estimated_teacher_count
      t.integer :estimated_mentor_count
    end
  end
end
