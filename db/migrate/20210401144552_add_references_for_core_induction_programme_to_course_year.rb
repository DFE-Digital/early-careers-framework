# frozen_string_literal: true

class AddReferencesForCoreInductionProgrammeToCourseYear < ActiveRecord::Migration[6.1]
  def change
    add_reference :core_induction_programmes, :course_year_one, foreign_key: { to_table: :course_years }, null: true, type: :uuid
    add_reference :core_induction_programmes, :course_year_two, foreign_key: { to_table: :course_years }, null: true, type: :uuid
  end
end
