# frozen_string_literal: true

# == Schema Information
#
# Table name: school_cohorts
#
#  id                         :uuid             not null, primary key
#  estimated_mentor_count     :integer
#  estimated_teacher_count    :integer
#  induction_programme_choice :string           default("not_yet_known"), not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  cohort_id                  :uuid             not null
#  school_id                  :uuid             not null
#
# Indexes
#
#  index_school_cohorts_on_cohort_id  (cohort_id)
#  index_school_cohorts_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (cohort_id => cohorts.id)
#  fk_rails_...  (school_id => schools.id)
#
class SchoolCohort < ApplicationRecord
  enum induction_programme_choice: {
    full_induction_programme: "full_induction_programme",
    core_induction_programme: "core_induction_programme",
    design_our_own: "design_our_own",
    not_yet_known: "not_yet_known",
  }

  belongs_to :cohort
  belongs_to :school
end
