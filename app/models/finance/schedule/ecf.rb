# frozen_string_literal: true

class Finance::Schedule::ECF < Finance::Schedule
  PERMITTED_COURSE_IDENTIFIERS = %w[ecf-induction ecf-mentor].freeze

  def self.default
    find_by(cohort: Cohort.next, schedule_identifier: "ecf-standard-september")
  end
end
