# frozen_string_literal: true

class Finance::Schedule::NPQSupport < Finance::Schedule
  IDENTIFIERS = %w[
    npq-additional-support-offer
  ].freeze

  def self.default
    Cohort.find_by(start_year: 2021).schedules.find_by(name: "NPQ ASO November")
  end
end
