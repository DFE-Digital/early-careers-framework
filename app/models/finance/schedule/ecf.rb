# frozen_string_literal: true

class Finance::Schedule::ECF < Finance::Schedule
  PERMITTED_COURSE_IDENTIFIERS = %w[ecf-induction ecf-mentor].freeze

  def self.default
    find_by(cohort: Cohort.active_registration_cohort, schedule_identifier: "ecf-standard-september")
  end

  def self.default_for(cohort:)
    find_by(cohort: cohort, schedule_identifier: "ecf-standard-september")
  end
end

require "finance/schedule/mentor"
