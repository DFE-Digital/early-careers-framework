# frozen_string_literal: true

class Finance::Schedule::NPQLeadership < Finance::Schedule
  IDENTIFIERS = %w[
    npq-senior-leadership
    npq-headship
    npq-executive-leadership
  ].freeze

  def self.default
    find_by(name: "NPQ Leadership November 2021")
  end
end
