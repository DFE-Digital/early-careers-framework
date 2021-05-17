# frozen_string_literal: true

class SchoolRecruitedTransitionComponent < BaseComponent
  def initialize(school_cohort:)
    @school_cohort = school_cohort
  end

  def render?
    return false unless school_cohort.school_chose_cip?
    return false if partnership.blank?

    partnership.in_challenge_window? && !partnership.challenged?
  end

private

  attr_reader :school_cohort

  def partnership
    @partnership ||= Partnership.find_by(
      school_id: school_cohort.school_id,
      cohort_id: school_cohort.cohort_id,
    )
  end

  delegate :delivery_partner, to: :partnership
  delegate :cohort, to: :school_cohort
end
