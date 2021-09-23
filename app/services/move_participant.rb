# frozen_string_literal: true

class MoveParticipant < BaseService
  attr_reader :participant_profile, :school

  def initialize(participant_profile:, school:)
    @participant_profile = participant_profile
    @school = school
  end

  def call
    cohort = participant_profile.school_cohort.cohort
    school_cohort = school.school_cohorts.find_by!(cohort: cohort)
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
