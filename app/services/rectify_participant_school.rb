# frozen_string_literal: true

class RectifyParticipantSchool < BaseService
  attr_reader :participant_profile, :from_school, :to_school, :transfer_pupil_premium_and_sparsity, :cohort, :school_cohort

  def initialize(participant_profile:, from_school:, to_school:, transfer_pupil_premium_and_sparsity: true)
    @participant_profile = participant_profile
    @from_school = from_school
    @to_school = to_school
    @transfer_pupil_premium_and_sparsity = transfer_pupil_premium_and_sparsity
  end

  # NOTE: Don't use this to move participants in cases where they have got a new job
  # and transferred to a different school. This is intended to fix issues with participants
  # that have been added to the wrong school by mistake or in a GIAS school closure/reopen
  # scenario.
  def call
    @cohort = participant_profile.school_cohort.cohort
    @school_cohort = to_school.school_cohorts.find_by(cohort:)
    return if school_cohort.blank?

    ActiveRecord::Base.transaction do
      rectify_teacher_profile
      rectify_mentor_pools if participant_profile.mentor?
      rectify_participant_profile
    end
  end

private

  def rectify_mentor_pools
    from_school.school_mentors.find_by(participant_profile:)&.update!(school: to_school)
  end

  def rectify_participant_profile
    attrs = { school_cohort: }

    if transfer_pupil_premium_and_sparsity
      attrs[:sparsity_uplift] = to_school.sparsity_uplift?(cohort.start_year)
      attrs[:pupil_premium_uplift] = to_school.pupil_premium_uplift?(cohort.start_year)
    end

    participant_profile.update!(attrs)
  end

  def rectify_teacher_profile
    participant_profile.teacher_profile.update!(school: to_school)
  end
end
