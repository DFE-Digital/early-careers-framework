# frozen_string_literal: true

class Finance::Schedule::NPQSpecialist < Finance::Schedule
  IDENTIFIERS = %w[
    npq-leading-teaching
    npq-leading-behaviour-culture
    npq-leading-teaching-development
  ].freeze

  def self.default
    find_by(name: "NPQ Specialist November 2021")
  end
end
