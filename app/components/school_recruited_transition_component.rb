# frozen_string_literal: true

class SchoolRecruitedTransitionComponent < BaseComponent
  def initialize(school_cohort:)
    @school_cohort = school_cohort
  end

  def render?
    return false if partnership.blank?
    return false unless could_show_banner_for_programme_choice?

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

  def could_show_banner_for_programme_choice?
    school_cohort.induction_programme_choice.in? %w[core_induction_programme design_our_own no_early_career_teachers]
  end

  delegate :lead_provider, to: :partnership
  delegate :delivery_partner, to: :partnership
  delegate :cohort, to: :school_cohort
end
