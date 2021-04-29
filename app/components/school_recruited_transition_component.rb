class SchoolRecruitedTransitionComponent < BaseComponent
  def initialize(school_cohort:)
    @school_cohort = school_cohort
  end

  def render?
    # TODO: Here we should check if this warning should be displayed or not based on school_cohort
    # This is dependent on: https://github.com/DFE-Digital/early-careers-framework/pull/288
    true
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

  def challenge_deadline_date
    # TODO: This is wrong and must be corrected
    Time.zone.now.to_date + 7.days    
  end

end
