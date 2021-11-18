# frozen_string_literal: true

class RectifyParticipantSchool < BaseService
  attr_reader :participant_profile, :school, :transfer_pupil_premium_and_sparsity

  def initialize(participant_profile:, school:, transfer_pupil_premium_and_sparsity: true)
    @participant_profile = participant_profile
    @school = school
    @transfer_pupil_premium_and_sparsity = transfer_pupil_premium_and_sparsity
  end

  # NOTE: Don't use this to move participants in cases where they have got a new job
  # and transferred to a different school. This is intended to fix issues with participants
  # that have been added to the wrong school by mistake or in a GIAS school closure/reopen
  # scenario.
  def call
    cohort = participant_profile.school_cohort.cohort
    school_cohort = school.school_cohorts.find_by(cohort: cohort)
    return if school_cohort.blank?

    ActiveRecord::Base.transaction do
      participant_profile.teacher_profile.update!(school: school)
      attrs = {
        school_cohort: school_cohort,
      }

      if transfer_pupil_premium_and_sparsity
        attrs[:sparsity_uplift] = school.sparsity_uplift?(cohort.start_year)
        attrs[:pupil_premium_uplift] = school.pupil_premium_uplift?(cohort.start_year)
      end

      participant_profile.update!(attrs)
    end
  end
end
