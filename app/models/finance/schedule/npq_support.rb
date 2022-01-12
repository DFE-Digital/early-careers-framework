# frozen_string_literal: true

class Finance::Schedule::NPQSupport < Finance::Schedule
  IDENTIFIERS = %w[
    npq-additional-support-offer
  ].freeze

  def self.default
    find_by(cohort: Cohort.current, schedule_identifier: "npq-aso-december")
  end
end
