# frozen_string_literal: true

class ChangeScheduleOnDuplicate < ChangeSchedule
  attribute :profile

  validates :profile, presence: true

  def call
    return if invalid?

    # The ChangeSchedule service would create an additional InductionRecord
    # that we want to avoid when deduping, so we update manually here.
    school = profile.latest_induction_record_for(cpd_lead_provider:).school
    profile.update!(
      school_cohort: SchoolCohort.find_by(school:, cohort: new_schedule.cohort),
      schedule: new_schedule,
    )
  end

  def participant_profile
    profile
  end
end
