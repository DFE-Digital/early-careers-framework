# frozen_string_literal: true

# == Schema Information
#
# Table name: early_career_teacher_profiles
#
#  id                          :uuid             not null, primary key
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  cohort_id                   :uuid
#  core_induction_programme_id :uuid
#  school_id                   :uuid             not null
#  user_id                     :uuid             not null
#
# Indexes
#
#  index_early_career_teacher_profiles_on_cohort_id   (cohort_id)
#  index_early_career_teacher_profiles_on_school_id   (school_id)
#  index_early_career_teacher_profiles_on_user_id     (user_id)
#  index_ect_profiles_on_core_induction_programme_id  (core_induction_programme_id)
#
# Foreign Keys
#
#  fk_rails_...  (cohort_id => cohorts.id)
#  fk_rails_...  (core_induction_programme_id => core_induction_programmes.id)
#  fk_rails_...  (school_id => schools.id)
#  fk_rails_...  (user_id => users.id)
#
class EarlyCareerTeacherProfile < ApplicationRecord
  belongs_to :user
  belongs_to :school
  belongs_to :core_induction_programme, optional: true
  belongs_to :cohort, optional: true
end
