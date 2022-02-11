# frozen_string_literal: true

class Finance::Schedule::NPQSpecialist < Finance::Schedule
  IDENTIFIERS = %w[
    npq-leading-teaching
    npq-leading-behaviour-culture
    npq-leading-teaching-development
  ].freeze

  def self.permitted_course_identifiers
    IDENTIFIERS
  end

  def self.default
    find_by(cohort: Cohort.current, schedule_identifier: "npq-specialist-spring")
  end
end
