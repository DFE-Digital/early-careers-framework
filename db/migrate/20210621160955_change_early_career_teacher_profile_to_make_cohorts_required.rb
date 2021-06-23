# frozen_string_literal: true

class ChangeEarlyCareerTeacherProfileToMakeCohortsRequired < ActiveRecord::Migration[6.1]
  def change
    add_check_constraint :early_career_teacher_profiles, "cohort_id IS NOT NULL", name: "early_career_teacher_profiles_cohort_id_null", validate: false
  end
end
