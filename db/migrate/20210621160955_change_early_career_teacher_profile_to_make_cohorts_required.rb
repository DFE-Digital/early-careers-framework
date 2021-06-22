# frozen_string_literal: true

class ChangeEarlyCareerTeacherProfileToMakeCohortsRequired < ActiveRecord::Migration[6.1]
  def change
    change_column_null :early_career_teacher_profiles, :cohort_id, false, Cohort.current.id
  end
end
