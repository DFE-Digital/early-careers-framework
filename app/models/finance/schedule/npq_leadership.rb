# frozen_string_literal: true

class Finance::Schedule::NPQLeadership < Finance::Schedule
  IDENTIFIERS = %w[
    npq-leading-teaching
    npq-leading-behaviour-culture
    npq-leading-teaching-development
  ].freeze

  def self.default
    find_by(name: "NPQ Leadership November 2021")
  end
end
