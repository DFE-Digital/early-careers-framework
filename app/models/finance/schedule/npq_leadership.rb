# frozen_string_literal: true

class Finance::Schedule::NPQLeadership < Finance::Schedule
  IDENTIFIERS = %w[
    npq-senior-leadership
    npq-headship
    npq-executive-leadership
  ].freeze

  def self.default
    find_by(cohort: Cohort.current, schedule_identifier: "npq-leadership-spring")
  end
end
