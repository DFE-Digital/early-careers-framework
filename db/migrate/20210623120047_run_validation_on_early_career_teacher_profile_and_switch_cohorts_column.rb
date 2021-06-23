# frozen_string_literal: true

class RunValidationOnEarlyCareerTeacherProfileAndSwitchCohortsColumn < ActiveRecord::Migration[6.1]
  def change
    validate_check_constraint :early_career_teacher_profiles, name: "early_career_teacher_profiles_cohort_id_null"
    safety_assured { change_column_null :early_career_teacher_profiles, :cohort_id, false }
    remove_check_constraint :early_career_teacher_profiles, name: "early_career_teacher_profiles_cohort_id_null"
  end
end
