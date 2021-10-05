# frozen_string_literal: true

class RectifyParticipantSchool < BaseService
  attr_reader :participant_profile, :school

  def initialize(participant_profile:, school:)
    @participant_profile = participant_profile
    @school = school
  end

  # NOTE: Don't use this to move participants in cases where they have got a new job
  # and transferred to a different school. This is intended to fix issues with participants
  # that have been added to the wrong school by mistake.
  def call
    cohort = participant_profile.school_cohort.cohort
    school_cohort = school.school_cohorts.find_by(cohort: cohort)
    return if school_cohort.blank?

    ActiveRecord::Base.transaction do
      participant_profile.teacher_profile.update!(school: school)
      participant_profile.update!(school_cohort: school_cohort,
                                  sparsity_uplift: school.sparsity_uplift?(cohort.start_year),
                                  pupil_premium_uplift: school.pupil_premium_uplift?(cohort.start_year))
    end
    true
  end
end
